//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - CollectionViewCell

/// An internal cell class for use in a `CollectionView`.
public final class CollectionViewCell: UICollectionViewCell, ItemCellView {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public private(set) var view: UIView?

  public var selectedBackgroundColor: UIColor?

  override public var isSelected: Bool {
    didSet {
      updateVisualHighlightState(isSelected)
    }
  }

  override public var isHighlighted: Bool {
    didSet {
      updateVisualHighlightState(isHighlighted)
    }
  }

  /// Pass a view for this cell's reuseID that the cell will pin to the edges of its `contentView`.
  public func setViewIfNeeded(view: UIView) {
    guard self.view == nil else {
      return
    }

    self.view = view
    normalViewBackgroundColor = view.backgroundColor

    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      view.topAnchor.constraint(equalTo: contentView.topAnchor),
      view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }

  override public func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes
  {
    let preferredAttributes: UICollectionViewLayoutAttributes

    // There's a downstream `EXC_BAD_ACCESS` crash that would indicate that `layoutAttributes` can
    // sometimes be `null`, even though it's bridged as `nonnull`. This check serves 2 purposes:
    // - Guarding against the case where `layoutAttributes` is `nil` (which prevents the
    //   aforementioned crash)
    // - Determining if we should do some custom sizing logic if our layout attributes instance
    //   conforms to `FittingPrioritiesProvidingLayoutAttributes`
    if
      let fittingPrioritiesProvider = layoutAttributes as? FittingPrioritiesProvidingLayoutAttributes
    {
      let horizontalFittingPriority = fittingPrioritiesProvider.horizontalFittingPriority
      let verticalFittingPriority = fittingPrioritiesProvider.verticalFittingPriority

      // In some cases, `contentView`'s required width and height constraints
      // (created from its auto-resizing mask) will not have the correct constants before invoking
      // `systemLayoutSizeFitting(...)`, causing the cell to size incorrectly. This seems to be a
      // UIKit bug.
      // https://openradar.appspot.com/radar?id=5025850143539200
      // The issue seems most common when the collection view's bounds change (on rotation).
      // We correct for this by updating `contentView.bounds`, which updates the constants used by
      // the width and height constraints created by the `contentView`'s auto-resizing mask.

      if
        horizontalFittingPriority == .required &&
        contentView.bounds.width != layoutAttributes.size.width
      {
        contentView.bounds.size.width = layoutAttributes.size.width
      }

      if
        verticalFittingPriority == .required &&
        contentView.bounds.height != layoutAttributes.size.height
      {
        contentView.bounds.size.height = layoutAttributes.size.height
      }

      let size: CGSize
      if horizontalFittingPriority != .required || verticalFittingPriority != .required {
        // Self-sizing is required in at least one dimension.
        size = super.systemLayoutSizeFitting(
          layoutAttributes.size,
          withHorizontalFittingPriority: horizontalFittingPriority,
          verticalFittingPriority: verticalFittingPriority)
      } else {
        // No self-sizing is required; respect whatever size the layout determined.
        size = layoutAttributes.size
      }

      layoutAttributes.size = size
      preferredAttributes = layoutAttributes
    } else {
      preferredAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    // On iOS 15, cells that return an unstable size can result in a layout recursion crash. The
    // root cause of these crashes is likely an ambiguous layout due to misconfigured constraints.
    // Unfortunately, finding each and every one of these ambiguous layouts can be challenging. This
    // code works around this new behavior / crash by giving up on self-sizing after 5 attempts.
    // Once a component has been sized differently 5 times, we assume that it has an ambiguous
    // layout and we simply return the last computed size for the remainder of the component's life.
    // We reset the count on cell reuse and when the cell is reconfigured in `CollectionView`'s
    // `configure` function.
    if CollectionViewConfiguration.shared.enableLayoutRecursionWorkaround {
      if let previousComputedSize = previousComputedSize, numberOfNewComputedSizes >= 5 {
        EpoxyLogger.shared.assertionFailure(
          "Layout recursion detected. View: \(view?.description ?? "nil view"). Size: \(preferredAttributes.size).")
        preferredAttributes.size = previousComputedSize
      }

      if preferredAttributes.size != previousComputedSize {
        numberOfNewComputedSizes += 1
        previousComputedSize = preferredAttributes.size
      }
    }

    return preferredAttributes
  }

  public override func prepareForReuse() {
    super.prepareForReuse()
    ephemeralViewCachedStateProvider?(cachedEphemeralState)
    resetSelfSizingLayoutRecursionPreventionState()
  }

  // MARK: Internal

  weak var accessibilityDelegate: CollectionViewCellAccessibilityDelegate?
  var ephemeralViewCachedStateProvider: ((Any?) -> Void)?

  func resetSelfSizingLayoutRecursionPreventionState() {
    guard CollectionViewConfiguration.shared.enableLayoutRecursionWorkaround else { return }
    numberOfNewComputedSizes = 0
    previousComputedSize = nil
  }

  // MARK: Private

  private var normalViewBackgroundColor: UIColor?

  private var numberOfNewComputedSizes = 0
  private var previousComputedSize: CGSize?

  private func updateVisualHighlightState(_ isVisuallyHighlighted: Bool) {
    if selectedBackgroundColor == nil { return }

    /// This is a temporary solution to support DLSComponentLibrary views that have a background color.
    /// This only works if subviews have a clear background color.
    if isVisuallyHighlighted {
      view?.backgroundColor = selectedBackgroundColor
    } else {
      view?.backgroundColor = normalViewBackgroundColor
    }
  }

}

// MARK: EphemeralCachedStateView

extension CollectionViewCell: EphemeralCachedStateView {
  public var cachedEphemeralState: Any? {
    get { (view as? EphemeralCachedStateView)?.cachedEphemeralState }
    set { (view as? EphemeralCachedStateView)?.cachedEphemeralState = newValue }
  }
}

// MARK: UIAccessibility

extension CollectionViewCell {
  public override var accessibilityElementsHidden: Bool {
    get {
      if let accessibilityCustomizable = view as? AccessibilityCustomizedView {
        return accessibilityCustomizable.accessibilityElementsHidden
      }
      return super.accessibilityElementsHidden
    }
    set { super.accessibilityElementsHidden = newValue }
  }

  public override func accessibilityElementDidBecomeFocused() {
    super.accessibilityElementDidBecomeFocused()
    accessibilityDelegate?.collectionViewCellDidBecomeFocused(cell: self)
  }

  public override func accessibilityElementDidLoseFocus() {
    super.accessibilityElementDidLoseFocus()
    accessibilityDelegate?.collectionViewCellDidLoseFocus(cell: self)
  }
}
