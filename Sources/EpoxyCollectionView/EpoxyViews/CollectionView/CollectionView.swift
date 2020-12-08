//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

/// A `UICollectionView` class that handles updates through its `setSections` method, and optionally
/// animates diffs.
open class CollectionView: UICollectionView, UICollectionViewDelegate {

  public typealias Cell = CollectionViewCell

  // MARK: Lifecycle

  public init(
    collectionViewLayout: UICollectionViewLayout,
    epoxyLogger: EpoxyLogging = DefaultEpoxyLogger())
  {
    self.epoxyLogger = epoxyLogger
    self.epoxyDataSource = CollectionViewEpoxyDataSource(
      epoxyLogger: epoxyLogger,
      usesBatchUpdatesForAllReloads: GlobalEpoxyConfig.shared.usesBatchUpdatesForAllCVReloads)
    super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
    setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  open override func traitCollectionDidChange(
    _ previousTraitCollection: UITraitCollection?)
  {
    super.traitCollectionDidChange(previousTraitCollection)
    if
      previousTraitCollection?.preferredContentSizeCategory != .unspecified &&
        previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
    {
      // Dynamic type settings changed so we need to
      // recalculate the heights of every cell.
      // This is done on the next runloop to ensure
      // every view's `traitCollectionDidChange` is called first,
      // which will update the layout properties of those views.
      DispatchQueue.main.async {
        self.recalculateCellHeights()
      }
    }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()

    if window == nil {
      scrollAnimator.cancelScrollToItem()
    }
  }

  // MARK: Public

  public func setSections(_ sections: [SectionModel]?, animated: Bool) {
    epoxyDataSource.setSections(sections, animated: animated)
  }

  public func scrollToItem(at dataID: AnyHashable, animated: Bool = false) {
    scrollToItem(at: dataID, position: .centeredVertically, animated: animated)
  }

  public func scrollToItem(at dataID: AnyHashable, position: ScrollPosition, animated: Bool) {
    guard let indexPath = indexPathForItem(at: dataID) else { return }

    if GlobalEpoxyConfig.shared.usesAccurateAnimatedScrollToItem && animated {
      scrollAnimator.accuratelyScrollToItem(at: indexPath, position: position)
    } else {
      scrollToItem(at: indexPath, at: position, animated: animated)
    }
  }

  /// Sets a given dataID's view as the first responder. The view must be rendered
  /// at the time this is called, so you should call `scrollToItem(at dataID: AnyHashable)`
  /// before calling this method if necessary. The view should also be set up to
  /// properly react to `becomeFirstResponder()` being called on it.
  ///
  /// - Parameter dataID: The dataID related to the view you want to becomeFirstResponder
  public func setItemAsFirstResponder(at dataID: AnyHashable) {
    guard
      let indexPath = indexPathForItem(at: dataID),
      let cell = cellForItem(at: indexPath) as? CollectionViewCell
      else {
        epoxyLogger.epoxyAssertionFailure("Tried to become first responder for a cell that was not visible.")
        return
    }
    cell.view?.becomeFirstResponder()
  }

  public func moveAccessibilityFocusToItem(
    at dataID: AnyHashable,
    notification: UIAccessibility.Notification = .layoutChanged)
  {
    guard
      let indexPath = indexPathForItem(at: dataID),
      let cell = cellForItem(at: indexPath) as? CollectionViewCell
      else {
        epoxyLogger.epoxyAssertionFailure("item not found")
        return
    }
    UIAccessibility.post(notification: notification, argument: cell)
  }

  public func moveAccessibilityFocusToLastFocusedElement() {
    guard let lastFocusedDataID = lastFocusedDataID else { return }
    moveAccessibilityFocusToItem(at: lastFocusedDataID)
  }

  public func recalculateCellHeights() {
    collectionViewLayout.invalidateLayout()
  }

  public func selectItem(at dataID: AnyHashable, animated: Bool) {
    guard let indexPath = indexPathForItem(at: dataID) else {
      epoxyLogger.epoxyAssertionFailure("item not found")
      return
    }
    selectItem(at: indexPath, animated: animated, scrollPosition: [])

    if let item = epoxyDataSource.item(at: indexPath),
      let cell = cellForItem(at: indexPath) as? EpoxyCell {
      item.configureStateChange(
        in: cell,
        with: EpoxyViewMetadata(traitCollection: traitCollection, state: .selected, animated: animated))
    }
  }

  public func deselectItem(at dataID: AnyHashable, animated: Bool) {
    guard let indexPath = indexPathForItem(at: dataID) else {
      return
    }
    deselectItem(at: indexPath, animated: animated)
    if let item = epoxyDataSource.item(at: indexPath),
      let cell = cellForItem(at: indexPath) as? EpoxyCell {
      item.configureStateChange(
        in: cell,
        with: EpoxyViewMetadata(traitCollection: traitCollection, state: .normal, animated: animated))
    }
  }

  /// Returns the current `SectionModel` for the section with the given `dataID` if it exists, else
  /// `nil`.
  public func section(at dataID: AnyHashable) -> SectionModel? {
    guard let sectionIndex = epoxyDataSource.internalData?.indexForSection(at: dataID) else {
      return nil
    }
    return epoxyDataSource.section(at: sectionIndex)
  }

  /// Returns the current model for the item with the given `dataID` if it exists, else `nil`.
  public func item(at dataID: AnyHashable) -> AnyItemModel? {
    guard let indexPath = epoxyDataSource.internalData?.indexPathForItem(at: dataID) else {
      return nil
    }
    return epoxyDataSource.item(at: indexPath)
  }

  /// Delegate for handling accessibility events.
  public weak var accessibilityDelegate: CollectionViewAccessibilityDelegate?

  /// Delegate for handling `UIScrollViewDelegate` callbacks related to scrolling.
  /// Ignores zooming delegate methods.
  public weak var scrollDelegate: UIScrollViewDelegate?

  /// Delegate for handling forwarded `UICollectionViewDelegateFlowLayout` methods or custom
  /// `UICollectionViewLayout` delegate methods.
  ///
  /// See `CollectionView+UICollectionViewFlowLayoutDelegate.swift` for an example of forwarding
  /// `UICollectionViewFlowLayoutDelegate` methods but with dataIDs instead of indexPaths/section
  /// indexes.
  public weak var layoutDelegate: AnyObject?

  /// Delegate which indicates when a epoxy item will be displayed, typically used
  /// for logging.
  public weak var displayDelegate: CollectionViewDisplayDelegate?

  /// Delegate for prefetching the contents of offscreen epoxy items that are likely to come on-
  /// screen soon.
  public weak var prefetchDelegate: CollectionViewPrefetchingDelegate? {
    didSet {
      prefetchDataSource = (prefetchDelegate != nil) ? self : nil
    }
  }

  /// The delegate that builds transition layouts.
  public weak var transitionLayoutDelegate: CollectionViewTransitionLayoutDelegate?

  /// The delegate that handles items reordering
  public weak var reorderingDelegate: CollectionViewEpoxyReorderingDelegate?

  /// Selection color for the `UICollectionViewCell`s of `ItemModel`s that have `isSelectable == true`
  public var selectionStyle = CellSelectionStyle.noBackground

  /// Whether to deselect items immediately after they are selected.
  public var autoDeselectItems: Bool = true

  /// Block that handles the pull to refresh action
  public var didTriggerPullToRefresh: ((UIRefreshControl) -> Void)? {
    didSet {
      pullToRefreshEnabled = didTriggerPullToRefresh != nil
    }
  }

  /// Pull to refresh control
  public lazy var pullToRefreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(didTriggerPullToRefreshControl(sender:)), for: .valueChanged)
    return refreshControl
  }()

  /// Whether or not pull to refresh is enabled
  public var pullToRefreshEnabled: Bool = false {
    didSet {
      // TODO: Once we drop iOS 9, set UIScrollView's refreshControl directly
      if pullToRefreshEnabled {
        addSubview(pullToRefreshControl)
      } else {
        pullToRefreshControl.removeFromSuperview()
      }
    }
  }

  public var visibleIndexPaths: [IndexPath] {
    return indexPathsForVisibleItems
  }

  public var viewsForVisibleItems: [UIView] {
    return visibleCells.compactMap({ ($0 as? Cell)?.view })
  }

  public var visibleEpoxyMetadata: VisibleEpoxyMetadata {
    // UICollectionView's indexPathsForVisibleItems is unsorted per Apple's documentation
    // https://developer.apple.com/documentation/uikit/uicollectionview/1618020-indexpathsforvisibleitems
    let visibleIndexPaths = self.visibleIndexPaths.sorted()
    var sectionMetadata = [VisibleSectionMetadata]()
    let visibleSections = Set<Int>(visibleIndexPaths.map({ $0.section })).sorted()

    for section in visibleSections {
      let sectionIndexPaths = visibleIndexPaths.filter({ $0.section == section })
      let modelMetadata: [VisibleItemMetadata] = sectionIndexPaths.compactMap { [weak self] indexPath in
        guard let cell = self?.cellForItem(at: indexPath) as? CollectionViewCell else { return nil }
        guard let epoxyItemWrapper = self?.epoxyDataSource.item(at: indexPath) else {
          epoxyLogger.epoxyAssertionFailure("model not found")
          return nil
        }
        return VisibleItemMetadata(
          model: epoxyItemWrapper,
          view: cell.view)
      }

      guard let section = epoxyDataSource.section(at: section) else {
        epoxyLogger.epoxyAssertionFailure("section not found")
        break
      }
      let newSectionMetadata = VisibleSectionMetadata(
        section: section,
        modelMetadata: modelMetadata)
      sectionMetadata.append(newSectionMetadata)
    }

    return VisibleEpoxyMetadata(
      sectionMetadata: sectionMetadata,
      containerView: self)
  }

  public func register(cellReuseID: String) {
    super.register(
      CollectionViewCell.self,
      forCellWithReuseIdentifier: cellReuseID)
  }

  public func register(supplementaryViewReuseID: String, forKind elementKind: String) {
    super.register(
      CollectionViewReusableView.self,
      forSupplementaryViewOfKind: elementKind,
      withReuseIdentifier: supplementaryViewReuseID)
  }

  public func configure(cell: Cell, with item: AnyItemModel) {
    configure(cell: cell, with: item, animated: false)
  }

  public func configure(
    supplementaryView: CollectionViewReusableView,
    with model: SupplementaryViewItemModeling)
  {
    model.configure(reusableView: supplementaryView, forTraitCollection: traitCollection)
    model.setBehavior(reusableView: supplementaryView)
  }

  public func reloadItem(at indexPath: IndexPath, animated: Bool) {
    if let cell = cellForItem(at: indexPath as IndexPath) as? CollectionViewCell,
      let item = epoxyDataSource.item(at: indexPath) {
      configure(cell: cell, with: item, animated: animated)
    }
  }

  public func apply(
    _ newData: InternalCollectionViewEpoxyData?,
    animated: Bool,
    changesetMaker: @escaping (InternalCollectionViewEpoxyData?) -> EpoxyChangeset?)
  {
    guard GlobalEpoxyConfig.shared.disablesCVBatchUpdateQueuing || !isUpdating else {
      queuedUpdate = (
        newData: newData,
        animated: animated,
        changesetMaker: changesetMaker)
      return
    }

    updateView(with: newData, animated: animated, changesetMaker: changesetMaker)
  }

  /// Convert a dataID to an index path, only for use in collection view layout delegate methods.
  public func indexPathForItem(at dataID: AnyHashable) -> IndexPath? {
    return epoxyDataSource.internalData?.indexPathForItem(at: dataID)
  }

  /// Convert an index path to a dataID, only for use in collection view layout delegate methods.
  public func dataIDForItem(at indexPath: IndexPath) -> AnyHashable? {
    return epoxyDataSource.item(at: indexPath)?.dataID
  }

  public func dataIDForItem(at point: CGPoint) -> AnyHashable? {
    guard
      let indexPath = indexPathForItem(at: point),
      let dataID = epoxyDataSource.item(at: indexPath)?.dataID
    else { return nil }
    return dataID
  }

  /// Convert a section index to a dataID, only for use in collection view layout delegate methods.
  public func dataIDForSection(at index: Int) -> AnyHashable? {
    return epoxyDataSource.section(at: index)?.dataID
  }

  // MARK: Fileprivate

  fileprivate let epoxyDataSource: CollectionViewEpoxyDataSource

  // MARK: Private

  private let epoxyLogger: EpoxyLogging

  private var queuedUpdate: (
    newData: InternalCollectionViewEpoxyData?,
    animated: Bool,
    changesetMaker: (InternalCollectionViewEpoxyData?) -> EpoxyChangeset?)?

  private var isUpdating = false
  private var ephemeralStateCache = [AnyHashable: RestorableState?]()
  private var lastFocusedDataID: AnyHashable?

  private lazy var scrollAnimator = CollectionViewScrollAnimator(
    collectionView: self,
    epoxyLogger: epoxyLogger)

  private func setUp() {
    // There are rendering issues in iOS 10 when using self-sizing supplementary views
    // when prefetching is enabled.
    // There are also self sizing invalidation issues in iOS 10 and iOS 11 if prefetching is enabled.
    isPrefetchingEnabled = false

    delegate = self
    epoxyDataSource.collectionView = self
    epoxyDataSource.reorderingDelegate = self
    dataSource = epoxyDataSource
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func configure(cell: Cell, with item: AnyItemModel, animated: Bool) {
    let cellSelectionStyle = item.selectionStyle ?? selectionStyle
    switch cellSelectionStyle {
    case .noBackground:
      cell.selectedBackgroundColor = nil
    case .color(let selectionColor):
      cell.selectedBackgroundColor = selectionColor
    }

    cell.accessibilityDelegate = self

    let metadata = EpoxyViewMetadata(
      traitCollection: traitCollection,
      state: cell.state,
      animated: animated)
    item.configure(cell: cell, with: metadata)
    item.setBehavior(cell: cell, with: metadata)
    if item.isSelectable {
      cell.accessibilityTraits = [cell.accessibilityTraits, .button]
    }

    cell.cachedEphemeralState = ephemeralStateCache[item.dataID] ?? nil
    cell.ephemeralViewCachedStateProvider = { [weak self] state in
      self?.ephemeralStateCache[item.dataID] = state
    }
  }

  private func updateView(
    with data: InternalCollectionViewEpoxyData?,
    animated: Bool,
    changesetMaker: @escaping (InternalCollectionViewEpoxyData?) -> EpoxyChangeset?)
  {
    isUpdating = true

    let performUpdates = {
      self.performBatchUpdates({
        self.performUpdates(data: data, changesetMaker: changesetMaker)
      }, completion: { _ in
        if let nextUpdate = self.queuedUpdate, self.window != nil {
          self.queuedUpdate = nil
          self.updateView(
            with: nextUpdate.newData,
            animated: nextUpdate.animated,
            changesetMaker: nextUpdate.changesetMaker)
        } else {
          self.completeUpdates()
        }
      })
    }

    if GlobalEpoxyConfig.shared.usesBatchUpdatesForAllCVReloads {
      if animated {
        performUpdates()
      } else {
        UIView.performWithoutAnimation {
          performUpdates()
        }
      }
    } else {
      guard animated,
        data != nil,
        let sectionCount = dataSource?.numberOfSections?(in: self),
        sectionCount > 0
      else
      {
        _ = changesetMaker(data)
        reloadData()
        completeUpdates()
        return
      }

      performUpdates()
    }
  }

  private func performUpdates(
    data: InternalCollectionViewEpoxyData?,
    changesetMaker: @escaping (InternalCollectionViewEpoxyData?) -> EpoxyChangeset?)
  {
    guard let changeset = changesetMaker(data) else { return }

    changeset.itemChangeset.updates.forEach { fromIndexPath, toIndexPath in
      if let cell = self.cellForItem(at: fromIndexPath as IndexPath) as? CollectionViewCell,
        let epoxyItem = self.epoxyDataSource.item(at: toIndexPath) {
        let metadata = EpoxyViewMetadata(traitCollection: traitCollection, state: cell.state, animated: true)
        epoxyItem.configure(cell: cell, with: metadata)
        epoxyItem.configureStateChange(in: cell, with: metadata)
      }
    }

    // TODO(ls): Make animations configurable

    deleteSections(changeset.sectionChangeset.deletes as IndexSet)
    deleteItems(at: changeset.itemChangeset.deletes)

    changeset.sectionChangeset.moves.forEach { fromIndex, toIndex in
      moveSection(fromIndex, toSection: toIndex)
    }

    changeset.itemChangeset.moves.forEach { fromIndexPath, toIndexPath in
      moveItem(at: fromIndexPath, to: toIndexPath)
    }

    insertSections(changeset.sectionChangeset.inserts as IndexSet)
    insertItems(at: changeset.itemChangeset.inserts)
  }

  private func resetBehaviors() {
    indexPathsForVisibleItems.forEach { indexPath in
      guard let cell = cellForItem(at: indexPath) as? CollectionViewCell else {
        epoxyLogger.epoxyAssertionFailure("Only CollectionViewCell and subclasses are allowed in a CollectionView.")
        return
      }
      if let item = epoxyDataSource.item(at: indexPath) {
        item.setBehavior(
          cell: cell,
          with: EpoxyViewMetadata(traitCollection: traitCollection, state: cell.state, animated: false))
      }
    }
  }

  private func completeUpdates() {
    resetBehaviors()
    isUpdating = false
  }

  @objc
  private func didTriggerPullToRefreshControl(sender: UIRefreshControl) {
    didTriggerPullToRefresh?(sender)
  }

  // MARK: UICollectionViewDelegate

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath)
  {
    guard
      let item = epoxyDataSource.item(at: indexPath),
      let section = epoxyDataSource.section(at: indexPath.section),
      let cell = cell as? Cell else
    {
      return
    }

    item.handleWillDisplay()
    (cell.view as? DisplayResponder)?.didDisplay(true)
    displayDelegate?.collectionView(self, willDisplayItem: item, with: cell.view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath)
  {
    guard
      let item = epoxyDataSource.itemIfPresent(at: indexPath),
      let section = epoxyDataSource.sectionIfPresent(at: indexPath.section),
      let cell = cell as? Cell else
    {
      return
    }

    item.handleDidEndDisplaying()
    (cell.view as? DisplayResponder)?.didDisplay(false)
    displayDelegate?.collectionView(self, didEndDisplayingItem: item, with: cell.view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplayingSupplementaryView view: UICollectionReusableView,
    forElementOfKind elementKind: String,
    at indexPath: IndexPath)
  {
    guard
      let section = epoxyDataSource.sectionIfPresent(at: indexPath.section),
      let item = epoxyDataSource.supplementaryItemIfPresent(ofKind: elementKind, at: indexPath) else
    {
      return
    }

    displayDelegate?.collectionView(self, didEndDisplayingSupplementaryItem: item, with: view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplaySupplementaryView view: UICollectionReusableView,
    forElementKind elementKind: String,
    at indexPath: IndexPath)
  {
    guard
      let section = epoxyDataSource.section(at: indexPath.section),
      let model = epoxyDataSource.supplementaryItemIfPresent(ofKind: elementKind, at: indexPath) else
    {
      epoxyLogger.epoxyAssertionFailure(
        "Supplementary item models not found for the given element kind and index path.")
      return
    }

    guard let view = view as? CollectionViewReusableView else {
      epoxyLogger.epoxyAssertionFailure(
        "Supplementary view does not match expected type CollectionViewReusableView.")
      return
    }

    displayDelegate?.collectionView(
      self,
      willDisplaySupplementaryItem: model,
      with: view,
      in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    shouldHighlightItemAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.item(at: indexPath) else {
      epoxyLogger.epoxyAssertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didHighlightItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        epoxyLogger.epoxyAssertionFailure("Index path is out of bounds")
        return
    }
    item.configureStateChange(
      in: cell,
      with: EpoxyViewMetadata(traitCollection: traitCollection, state: .highlighted, animated: true))
    (cell.view as? Highlightable)?.didHighlight(true)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didUnhighlightItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        return
    }
    item.configureStateChange(
      in: cell,
      with: EpoxyViewMetadata(traitCollection: traitCollection, state: .normal, animated: true))
    (cell.view as? Highlightable)?.didHighlight(false)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    shouldSelectItemAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.item(at: indexPath) else {
      epoxyLogger.epoxyAssertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        epoxyLogger.epoxyAssertionFailure("Index path is out of bounds")
        return
    }
    let metadata = EpoxyViewMetadata(
      traitCollection: traitCollection,
      state: .selected,
      animated: true)
    item.configureStateChange(in: cell, with: metadata)
    item.handleDidSelect(cell, with: metadata)
    (cell.view as? Selectable)?.didSelect()

    if autoDeselectItems {
      // If collectionView modifications have been made, indexPath may no longer point to the correct
      // item so we find the all currently selected items and deselect them.
      // In practice this should always be a single item
      if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
        selectedIndexPaths.forEach { collectionView.deselectItem(at: $0, animated: true) }
      }
      item.configureStateChange(
        in: cell,
        with: EpoxyViewMetadata(traitCollection: traitCollection, state: .normal, animated: true))
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    shouldDeselectItemAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.item(at: indexPath) else {
      epoxyLogger.epoxyAssertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        return
    }
    item.configureStateChange(
      in: cell,
      with: EpoxyViewMetadata(traitCollection: traitCollection, state: .normal, animated: true))
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
    newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
  {
    guard let delegate = transitionLayoutDelegate else {
      return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
    return delegate.collectionView(collectionView, transitionLayoutForOldLayout: fromLayout, newLayout: toLayout)
  }

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScroll?(scrollView)

    // Allow the programmatic scroll-to-item to be interrupted / cancelled if the user tries to
    // scroll.
    let isUserInitiatedScrolling = scrollView.isDragging && scrollView.isTracking
    if isUserInitiatedScrolling {
      scrollAnimator.cancelScrollToItem()
    }
  }

  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
  }

  public func scrollViewWillEndDragging(
    _ scrollView: UIScrollView, withVelocity
    velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    scrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }

  public func scrollViewDidEndDragging(
    _ scrollView: UIScrollView, willDecelerate
    decelerate: Bool)
  {
    scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
  }

  public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    let shouldScrollToTop = scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true

    if shouldScrollToTop {
      scrollAnimator.cancelScrollToItem()
    }

    return shouldScrollToTop
  }

  public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
  }

  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
  }

  // MARK: Unavailable Methods

  @available (*, unavailable, message: "You shouldn't be registering cell classes on a CollectionView. The CollectionViewEpoxyDataSource handles this for you.")
  final override public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
    super.register(cellClass, forCellWithReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering cell nibs on a CollectionView. The CollectionViewEpoxyDataSource handles this for you.")
  final override public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
    super.register(nib, forCellWithReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering supplementary view nibs on a CollectionView. The CollectionViewEpoxyDataSource handles this for you.")
  final override public func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
    super.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering supplementary view classes on a CollectionView. The CollectionViewEpoxyDataSource handles this for you.")
  final override public func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
    super.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
  }

}

// MARK: UICollectionViewDataSourcePrefetching

extension CollectionView: UICollectionViewDataSourcePrefetching {
  public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    let models = indexPaths.compactMap(epoxyDataSource.item(at:))

    guard !models.isEmpty else { return }

    prefetchDelegate?.collectionView(self, prefetch: models)
  }

  public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    let models = indexPaths.compactMap(epoxyDataSource.item(at:))

    guard !models.isEmpty else { return }

    prefetchDelegate?.collectionView(self, cancelPrefetchingOf: models)
  }
}

// MARK: CollectionViewDataSourceReorderingDelegate

extension CollectionView: CollectionViewDataSourceReorderingDelegate {
  func dataSource(_ dataSource: CollectionViewEpoxyDataSource,
    moveItemWithDataID dataID: AnyHashable,
    inSectionWithDataID fromSectionDataID: AnyHashable,
    toSectionWithDataID toSectionDataID: AnyHashable,
    withDestinationDataId destinationDataId: AnyHashable)
  {
    reorderingDelegate?.collectionView(
      self, moveItemWithDataID: dataID,
      inSectionWithDataID: fromSectionDataID,
      toSectionWithDataID: toSectionDataID,
      withDestinationDataId: destinationDataId)
  }
}

// MARK: CollectionViewCellAccessibilityDelegate

extension CollectionView: CollectionViewCellAccessibilityDelegate {

  // MARK: Internal

  func collectionViewCellDidBecomeFocused(cell: CollectionViewCell) {
    guard
      let model = itemForCell(cell),
      let section = sectionForCell(cell)
      else { return }
    lastFocusedDataID = model.dataID

    accessibilityDelegate?.collectionView(
      self,
      itemDidBecomeFocused: model,
      with: cell.view,
      in: section)
  }

  func collectionViewCellDidLoseFocus(cell: CollectionViewCell) {
    guard
      let model = itemForCell(cell),
      let section = sectionForCell(cell)
      else { return }

    accessibilityDelegate?.collectionView(
      self,
      itemDidLoseFocus: model,
      with: cell.view,
      in: section)
  }

  // MARK: Private

  private func itemForCell(_ cell: CollectionViewCell) -> AnyItemModel? {
    guard
      let indexPath = indexPath(for: cell),
      let model = epoxyDataSource.item(at: indexPath)
    else {
        epoxyLogger.epoxyAssertionFailure("item not found")
        return nil
    }
    return model
  }

  private func sectionForCell(_ cell: CollectionViewCell) -> SectionModel? {
    guard
      let indexPath = indexPath(for: cell),
      let section = epoxyDataSource.section(at: indexPath.section)
    else {
      epoxyLogger.epoxyAssertionFailure("item not found")
      return nil
    }
    return section
  }
}
