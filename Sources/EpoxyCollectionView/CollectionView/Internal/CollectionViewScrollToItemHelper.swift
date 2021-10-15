// Created by Bryan Keller on 10/20/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - CollectionViewScrollToItemHelper

/// This class facilitates scrolling to an item at a particular index path, since the built-in
/// scroll-to-item functionality is broken for self-sizing cells.
///
/// The fix for the animated case involves driving the scroll animation ourselves using a
/// `CADisplayLink`.
///
/// The fix for the non-animated case involves repeatedly calling the UIKit `scrollToItem`
/// implementation until we land at a stable content offset.
final class CollectionViewScrollToItemHelper {

  // MARK: Lifecycle

  /// The collection view instance is weakly-held.
  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
  }

  // MARK: Internal

  func accuratelyScrollToItem(
    at indexPath: IndexPath,
    position: UICollectionView.ScrollPosition,
    animated: Bool)
  {
    if animated {
      accurateScrollToItemWithAnimation(itemIndexPath: indexPath, position: position)
    } else {
      accurateScrollToItemWithoutAnimation(itemIndexPath: indexPath, position: position)
    }
  }

  /// Cancels an in-flight animated scroll-to-item, if there is one.
  ///
  /// Call this function if your collection view is about to deallocate. For example, you can call
  /// this from `viewWillDisappear` in a view controller, or `didMoveToWindow` when `window == nil`
  /// in a view. You can also call this when a user interacts with the collection view so that
  /// control is returned to the user.
  func cancelAnimatedScrollToItem() {
    scrollToItemContext = nil
  }

  // MARK: Private

  private weak var collectionView: UICollectionView?
  private weak var scrollToItemDisplayLink: CADisplayLink?

  private var scrollToItemContext: ScrollToItemContext? {
    willSet {
      scrollToItemDisplayLink?.invalidate()
    }
  }

  private func accurateScrollToItemWithoutAnimation(
    itemIndexPath: IndexPath,
    position: UICollectionView.ScrollPosition)
  {
    guard let collectionView = collectionView else { return }

    // Programmatically scrolling to an item, even without an animation, when using self-sizing
    // cells usually results in slightly incorrect scroll offsets. By invoking `scrollToItem`
    // multiple times in a row, we can force the collection view to eventually end up in the right
    // spot.
    //
    // This usually only takes 3 iterations: 1 to get to an estimated offset, 1 to get to the
    // final offset, and 1 to verify that we're at the final offset. If it takes more than 5
    // attempts, we'll stop trying since we're blocking the main thread during these attempts.
    var previousContentOffset = CGPoint(
      x: CGFloat.greatestFiniteMagnitude,
      y: CGFloat.greatestFiniteMagnitude)
    var numberOfAttempts = 1
    while
      (abs(collectionView.contentOffset.x - previousContentOffset.x) >= 1 ||
        abs(collectionView.contentOffset.y - previousContentOffset.y) >= 1) &&
      numberOfAttempts <= 5
    {
      if numberOfAttempts > 1 {
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
      }

      previousContentOffset = collectionView.contentOffset
      collectionView.scrollToItem(at: itemIndexPath, at: position, animated: false)

      numberOfAttempts += 1
    }

    if numberOfAttempts > 5 {
      EpoxyLogger.shared.warn(
        "Gave up scrolling to an item without an animation because it took more than 5 attempts.")
    }
  }

  private func accurateScrollToItemWithAnimation(
    itemIndexPath: IndexPath,
    position: UICollectionView.ScrollPosition)
  {
    guard let collectionView = collectionView else { return }

    let scrollPosition: UICollectionView.ScrollPosition
    if position == [] {
      guard
        let closestScrollPosition = closestRestingScrollPosition(
          forTargetItemIndexPath: itemIndexPath,
          collectionView: collectionView)
      else
      {
        // If we can't find a closest-scroll-position, it's because the item is already fully
        // visible. In this situation, we can return early / do nothing.
        return
      }
      scrollPosition = closestScrollPosition
    } else {
      scrollPosition = position
    }

    scrollToItemContext = ScrollToItemContext(
      targetIndexPath: itemIndexPath,
      targetScrollPosition: scrollPosition,
      animationStartTime: CACurrentMediaTime())

    startScrollingTowardTargetItem()
  }

  private func startScrollingTowardTargetItem() {
    let scrollToItemDisplayLink = CADisplayLink(
      target: self,
      selector: #selector(scrollToItemDisplayLinkFired))
    if #available(iOS 15.0, *) {
      scrollToItemDisplayLink.preferredFrameRateRange = CAFrameRateRange(
        minimum: 80,
        maximum: 120,
        preferred: 120)
    }
    scrollToItemDisplayLink.add(to: .main, forMode: .common)
    self.scrollToItemDisplayLink = scrollToItemDisplayLink
  }

  /// Removes our scroll-to-item context and finalizes our custom scroll-to-item by invoking the
  /// original function. This guarantees that our last frame of animation ends us in the correct
  /// position.
  private func finalizeScrollingTowardItem(
    for scrollToItemContext: ScrollToItemContext,
    animated: Bool)
  {
    self.scrollToItemContext = nil

    collectionView?.scrollToItem(
      at: scrollToItemContext.targetIndexPath,
      at: scrollToItemContext.targetScrollPosition,
      animated: animated)

    if let collectionView = collectionView, !animated {
      collectionView.delegate?.scrollViewDidEndScrollingAnimation?(collectionView)
    }
  }

  @objc
  private func scrollToItemDisplayLinkFired() {
    guard let collectionView = collectionView else { return }
    guard let scrollToItemContext = scrollToItemContext else {
      EpoxyLogger.shared.assertionFailure(
        """
        Expected `scrollToItemContext` to be non-nil when programmatically scrolling toward an \
        item.
        """)
      return
    }

    // Don't start programmatically scrolling until we have a greater-than`.zero` `bounds.size`.
    // This might happen if `scrollToItem` is called before the collection view has been laid out.
    guard collectionView.bounds.width > 0 && collectionView.bounds.height > 0 else { return }

    // Figure out which axis to use for scrolling.
    guard let scrollAxis = self.scrollAxis(for: collectionView) else {
      // If we can't determine a scroll axis, it's either due to the collection view being too small
      // to be scrollable along either axis, or the collection view being scrollable along both
      // axes. In either scenario, we can just fall back to the default scroll-to-item behavior.
      finalizeScrollingTowardItem(for: scrollToItemContext, animated: true)
      return
    }

    let maximumPerAnimationTickOffset = self.maximumPerAnimationTickOffset(
      for: scrollAxis,
      collectionView: collectionView)

    // After 3 seconds, the scrolling reaches is maximum speed.
    let secondsSinceAnimationStart = CACurrentMediaTime() - scrollToItemContext.animationStartTime
    let offset = maximumPerAnimationTickOffset * CGFloat(min(secondsSinceAnimationStart / 3, 1))

    // Apply this scroll animation "tick's" offset adjustment. This is what actually causes the
    // scroll position to change, giving the illusion of smooth scrolling as this happens 60+ times
    // per second.
    let positionBeforeLayout = positionRelativeToVisibleBounds(
      forTargetItemIndexPath: scrollToItemContext.targetIndexPath,
      collectionView: collectionView)

    switch positionBeforeLayout {
    case .before:
      collectionView.contentOffset[scrollAxis] -= offset

    case .after:
      collectionView.contentOffset[scrollAxis] += offset

    // If the target item is partially or fully visible, then we don't need to apply a full `offset`
    // adjustment of the content offset. Instead, we do some special logic to look at how close we
    // currently are to the target origin, then change our content offset based on how far away we
    // are from that target.
    case .partiallyOrFullyVisible(let frame):
      let targetContentOffset = targetContentOffsetForVisibleItem(
        withFrame: frame,
        inBounds: collectionView.bounds,
        contentSize: collectionView.contentSize,
        adjustedContentInset: collectionView.adjustedContentInset,
        targetScrollPosition: scrollToItemContext.targetScrollPosition,
        scrollAxis: scrollAxis)

      let targetOffset = targetContentOffset[scrollAxis]
      let currentOffset = collectionView.contentOffset[scrollAxis]
      let distanceToTargetOffset = targetOffset - currentOffset

      switch distanceToTargetOffset {
      case ...(-1):
        collectionView.contentOffset[scrollAxis] += max(-offset, distanceToTargetOffset)
      case 1...:
        collectionView.contentOffset[scrollAxis] += min(offset, distanceToTargetOffset)
      default:
        finalizeScrollingTowardItem(for: scrollToItemContext, animated: false)
      }

    case .none:
      break
    }

    collectionView.setNeedsLayout()
    collectionView.layoutIfNeeded()
  }

  private func scrollAxis(for collectionView: UICollectionView) -> ScrollAxis? {
    let availableWidth = collectionView.bounds.width -
      collectionView.adjustedContentInset.left -
      collectionView.adjustedContentInset.right
    let availableHeight = collectionView.bounds.height -
      collectionView.adjustedContentInset.top -
      collectionView.adjustedContentInset.bottom
    let scrollsHorizontally = collectionView.contentSize.width > availableWidth
    let scrollsVertically = collectionView.contentSize.height > availableHeight

    switch (scrollsHorizontally: scrollsHorizontally, scrollsVertically: scrollsVertically) {
    case (scrollsHorizontally: false, scrollsVertically: true):
      return .vertical

    case (scrollsHorizontally: true, scrollsVertically: false):
      return .horizontal

    case (scrollsHorizontally: true, scrollsVertically: true),
         (scrollsHorizontally: false, scrollsVertically: false):
      return nil
    }
  }

  private func maximumPerAnimationTickOffset(
    for scrollAxis: ScrollAxis,
    collectionView: UICollectionView)
    -> CGFloat
  {
    let offset: CGFloat
    switch scrollAxis {
    case .vertical: offset = collectionView.bounds.height
    case .horizontal: offset = collectionView.bounds.width
    }

    return offset * 1.5
  }

  /// Returns the position (before, after, visible) of an item relative to the current viewport.
  /// Note that the position (before, after, visible) is agnostic of scroll axis.
  private func positionRelativeToVisibleBounds(
    forTargetItemIndexPath targetIndexPath: IndexPath,
    collectionView: UICollectionView)
    -> PositionRelativeToVisibleBounds?
  {
    let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems.sorted()

    if let targetItemFrame = collectionView.layoutAttributesForItem(at: targetIndexPath)?.frame {
      return .partiallyOrFullyVisible(frame: targetItemFrame)
    } else if
      let firstVisibleIndexPath = indexPathsForVisibleItems.first,
      targetIndexPath < firstVisibleIndexPath
    {
      return .before
    } else if
      let lastVisibleIndexPath = indexPathsForVisibleItems.last,
      targetIndexPath > lastVisibleIndexPath
    {
      return .after
    } else {
      EpoxyLogger.shared.assertionFailure(
        "Could not find a position relative to the visible bounds for item at \(targetIndexPath)")
      return nil
    }
  }

  /// If a scroll position is not specified, this function is called to find the closest scroll
  /// position to make the item as visible as possible. If the item is already completely visible,
  /// this function returns `nil`.
  private func closestRestingScrollPosition(
    forTargetItemIndexPath targetIndexPath: IndexPath,
    collectionView: UICollectionView)
    -> UICollectionView.ScrollPosition?
  {
    guard let scrollAxis = self.scrollAxis(for: collectionView) else {
      return nil
    }

    let positionRelativeToVisibleBounds = self.positionRelativeToVisibleBounds(
      forTargetItemIndexPath: targetIndexPath,
      collectionView: collectionView)

    let insetBounds = collectionView.bounds.inset(by: collectionView.adjustedContentInset)

    switch (scrollAxis, positionRelativeToVisibleBounds) {
    case (.vertical, .before):
      return .top
    case (.vertical, .after):
      return .bottom
    case (.vertical, .partiallyOrFullyVisible(let itemFrame)):
      guard !insetBounds.contains(itemFrame) else { return nil }
      return itemFrame.midY < insetBounds.midY ? .top : .bottom
    case (.horizontal, .before):
      return .left
    case (.horizontal, .after):
      return .right
    case (.horizontal, .partiallyOrFullyVisible(let itemFrame)):
      guard !insetBounds.contains(itemFrame) else { return nil }
      return itemFrame.midX < insetBounds.midX ? .left : .right
    default:
      EpoxyLogger.shared.assertionFailure("Unsupported scroll position.")
      return nil
    }
  }

  /// Returns the correct content offset for a scroll-to-item action for the current viewport.
  ///
  /// This will be used to determine how much farther we need to programmatically scroll on each
  /// animation tick.
  private func targetContentOffsetForVisibleItem(
    withFrame itemFrame: CGRect,
    inBounds bounds: CGRect,
    contentSize: CGSize,
    adjustedContentInset: UIEdgeInsets,
    targetScrollPosition: UICollectionView.ScrollPosition,
    scrollAxis: ScrollAxis)
    -> CGPoint
  {
    let itemPosition, itemSize, viewportSize, minContentOffset, maxContentOffset: CGFloat
    let visibleBounds = bounds.inset(by: adjustedContentInset)
    switch scrollAxis {
    case .vertical:
      itemPosition = itemFrame.minY
      itemSize = itemFrame.height
      viewportSize = visibleBounds.height
      minContentOffset = -adjustedContentInset.top
      maxContentOffset = -adjustedContentInset.top + contentSize.height - visibleBounds.height
    case .horizontal:
      itemPosition = itemFrame.minX
      itemSize = itemFrame.width
      viewportSize = visibleBounds.width
      minContentOffset = -adjustedContentInset.left
      maxContentOffset = -adjustedContentInset.left + contentSize.width - visibleBounds.width
    }

    let newOffset: CGFloat
    switch targetScrollPosition {
    case .top, .left:
      newOffset = itemPosition + minContentOffset
    case .bottom, .right:
      newOffset = itemPosition + itemSize - viewportSize + minContentOffset
    case .centeredVertically, .centeredHorizontally:
      newOffset = itemPosition + (itemSize / 2) - (viewportSize / 2) + minContentOffset
    default:
      EpoxyLogger.shared.assertionFailure("Unsupported scroll position.")
      return itemFrame.origin
    }

    let clampedOffset = min(max(newOffset, minContentOffset), maxContentOffset)

    var targetOffset = itemFrame.origin
    targetOffset[scrollAxis] = clampedOffset
    return targetOffset
  }

}

// MARK: - ScrollToItemContext

private struct ScrollToItemContext {
  let targetIndexPath: IndexPath
  let targetScrollPosition: UICollectionView.ScrollPosition
  let animationStartTime: CFTimeInterval
}

// MARK: - ScrollAxis

private enum ScrollAxis {
  case vertical
  case horizontal
}

// MARK: - PositionRelativeToVisibleBounds

private enum PositionRelativeToVisibleBounds {
  case before
  case after
  case partiallyOrFullyVisible(frame: CGRect)
}

// MARK: - CGPoint

extension CGPoint {
  fileprivate subscript(axis: ScrollAxis) -> CGFloat {
    get {
      switch axis {
      case .vertical: return y
      case .horizontal: return x
      }
    }
    set {
      switch axis {
      case .vertical: y = newValue
      case .horizontal: x = newValue
      }
    }
  }
}
