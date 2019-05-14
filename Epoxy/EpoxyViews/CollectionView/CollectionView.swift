//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// A `UICollectionView` class that handles updates through its `setSections` method, and optionally animates diffs.
open class CollectionView: UICollectionView,
  TypedEpoxyInterface,
  InternalEpoxyInterface,
  UICollectionViewDelegate
{

  public typealias DataType = InternalCollectionViewEpoxyData
  public typealias Cell = CollectionViewCell

  // MARK: Lifecycle

  public init(collectionViewLayout: UICollectionViewLayout) {
    self.epoxyDataSource = CollectionViewEpoxyDataSource()
    super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
    setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public func setSections(_ sections: [EpoxySection]?, animated: Bool) {
    epoxyDataSource.setSections(sections, animated: animated)
  }

  public func scrollToItem(at dataID: String, animated: Bool = false) {
    scrollToItem(at: dataID, position: .centeredVertically, animated: animated)
  }

  public func scrollToItem(at dataID: String, position: UICollectionView.ScrollPosition, animated: Bool) {
    if let indexPath = indexPathForItem(at: dataID) {
      scrollToItem(at: indexPath, at: position, animated: animated)
    }
  }

  /// Sets a given dataID's view as the first responder. The view must be rendered
  /// at the time this is called, so you should call `scrollToItem(at dataID: String)`
  /// before calling this method if necessary. The view should also be set up to
  /// properly react to `becomeFirstResponder()` being called on it.
  ///
  /// - Parameter dataID: The dataID related to the view you want to becomeFirstResponder
  public func setItemAsFirstResponder(at dataID: String) {
    guard
      let indexPath = indexPathForItem(at: dataID),
      let cell = cellForItem(at: indexPath) as? CollectionViewCell
      else {
        assertionFailure("Tried to become first responder for a cell that was not visible.")
        return
    }
    cell.view?.becomeFirstResponder()
  }

  public func moveAccessibilityFocusToItem(
    at dataID: String,
    notification: UIAccessibility.Notification = .layoutChanged)
  {
    guard
      let indexPath = indexPathForItem(at: dataID),
      let cell = cellForItem(at: indexPath) as? CollectionViewCell
      else {
        assertionFailure("item not found")
        return
    }
    UIAccessibility.post(notification: notification, argument: cell)
  }

  public func recalculateCellHeights() {
    collectionViewLayout.invalidateLayout()
  }

  public func updateItem(
    at dataID: String,
    with item: EpoxyableModel,
    animated: Bool)
  {
    epoxyDataSource.updateItem(at: dataID, with: item, animated: animated)
  }

  public func selectItem(at dataID: String, animated: Bool) {
    guard let indexPath = indexPathForItem(at: dataID) else {
      assertionFailure("item not found")
      return
    }
    selectItem(at: indexPath, animated: animated, scrollPosition: [])

    if let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = cellForItem(at: indexPath) as? EpoxyCell {
      item.configure(cell: cell, forTraitCollection: traitCollection, state: .selected)
    }
  }

  public func deselectItem(at dataID: String, animated: Bool) {
    guard let indexPath = indexPathForItem(at: dataID) else {
      return
    }
    deselectItem(at: indexPath, animated: animated)
    if let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = cellForItem(at: indexPath) as? EpoxyCell {
      item.configure(cell: cell, forTraitCollection: traitCollection, state: .normal)
    }
  }

  /// Returns the userInfo value for a given key from the section at the provided dataID
  public func sectionUserInfoValue<T>(at dataID: String, for key: EpoxyUserInfoKey) -> T? {
    guard let sectionIndex = epoxyDataSource.internalData?.indexForSection(at: dataID) else {
      return nil
    }
    return epoxyDataSource.epoxySection(at: sectionIndex)?.userInfo[key] as? T
  }

  /// Returns the userInfo value for a given key from the item at the provided dataID
  public func itemUserInfoValue<T>(at dataID: String, for key: EpoxyUserInfoKey) -> T? {
    guard let indexPath = epoxyDataSource.internalData?.indexPathForItem(at: dataID) else {
      return nil
    }
    return epoxyDataSource.epoxyItem(at: indexPath)?.userInfo[key] as? T
  }

  /// CollectionView does not currently support divider hiding.
  public func hideBottomDivider(for dataIDs: [String]) {
    // TODO: Refactor to support layout specific data in epoxy item models
  }

  /// Delegate for handling `UIScrollViewDelegate` callbacks related to scrolling.
  /// Ignores zooming delegate methods.
  public weak var scrollDelegate: UIScrollViewDelegate?

  /// Delegate for handling forwarded UICollectionViewDelegateFlowLayout methods or custom UICollectionViewLayout delegate methods.
  ///
  /// See `CollectionView+UICollectionViewFlowLayoutDelegate.swift` for an example of forwarding UICollectionViewFlowLayoutDelegate methods but with dataIDs instead of indexPaths/section indexes
  public weak var layoutDelegate: AnyObject?

  /// Delegate which indicates when a epoxy item will be displayed, typically used
  /// for logging.
  public weak var epoxyItemDisplayDelegate: CollectionViewEpoxyItemDisplayDelegate?

  /// Data source for prefetching the contents of offscreen epoxy items that are likely to come on-
  /// screen soon.
  public weak var epoxyItemPrefetchDataSource: CollectionViewEpoxyItemDataSourcePrefetching? {
    didSet {
      prefetchDataSource = (epoxyItemPrefetchDataSource != nil) ? self : nil
    }
  }

  /// Selection color for the `UICollectionViewCell`s of `EpoxyModel`s that have `isSelectable == true`
  public var selectionStyle = CellSelectionStyle.noBackground

  /// Whether to deselect items immediately after they are selected.
  public var autoDeselectItems: Bool = true

  /// The delegate that builds transition layouts.
  public weak var transitionLayoutDelegate: CollectionViewTransitionLayoutDelegate?

  /// The delegate that handles items reordering
  public weak var reorderingDelegate: CollectionViewEpoxyReorderingDelegate?

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

  public func configure(cell: Cell, with item: EpoxyModelWrapper) {
    configure(cell: cell, with: item, animated: false)
  }

  public func configure(
    supplementaryView: CollectionViewReusableView,
    with model: SupplementaryViewEpoxyableModel)
  {
    model.configure(reusableView: supplementaryView, forTraitCollection: traitCollection)
    model.setBehavior(reusableView: supplementaryView)
  }

  public func reloadItem(at indexPath: IndexPath, animated: Bool) {
    if let cell = cellForItem(at: indexPath as IndexPath) as? CollectionViewCell,
      let item = epoxyDataSource.epoxyItem(at: indexPath) {
      configure(cell: cell, with: item, animated: animated)
    }
  }

  public func apply(
    _ newData: DataType?,
    animated: Bool,
    changesetMaker: @escaping (DataType?) -> EpoxyChangeset?)
  {
    guard !isUpdating else {
      queuedUpdate = (
        newData: newData,
        animated: animated,
        changesetMaker: changesetMaker)
      return
    }

    updateView(with: newData, animated: animated, changesetMaker: changesetMaker)
  }

  /// Convert a dataID to an index path, only for use in collection view layout delegate methods.
  public func indexPathForItem(at dataID: String) -> IndexPath? {
    return epoxyDataSource.internalData?.indexPathForItem(at: dataID)
  }

  /// Convert an index path to a dataID, only for use in collection view layout delegate methods.
  public func dataIDForItem(at indexPath: IndexPath) -> String? {
    return epoxyDataSource.epoxyItem(at: indexPath)?.dataID
  }

  public func dataIDForItem(at point: CGPoint) -> String? {
    guard
      let indexPath = indexPathForItem(at: point),
      let dataID = epoxyDataSource.epoxyItem(at: indexPath)?.dataID
    else { return nil }
    return dataID
  }

  /// Convert a section index to a dataID, only for use in collection view layout delegate methods.
  public func dataIDForSection(at index: Int) -> String? {
    return epoxyDataSource.epoxySection(at: index)?.dataID
  }

  /// Adds an infinite scrolling loading view and sets up a delegate to receive scrolling callbacks.
  /// Note that infinite scrolling is only supported on vertically scrolling CollectionViews.
  ///
  /// - Parameters:
  ///   - delegate: infinite scrolling delegate to handle when more content should be loaded.
  ///   - loaderView: the view to use as the loading spinner at the bottom of the scroll view.
  public func addInfiniteScrolling<LoaderView>(
    delegate: InfiniteScrollingDelegate,
    loaderView: LoaderView)
    where LoaderView: UIView, LoaderView: Animatable
  {
    // If infinite loading has already been added, just no-op.
    // If you need to change the loading spinner, please call `removeInfiniteScrolling` before
    // calling this method again.
    if infiniteScrollingLoader != nil {
      return
    }

    let height = loaderView.compressedHeight(forWidth: bounds.width)
    loaderView.translatesAutoresizingMaskIntoConstraints = true
    loaderView.frame.size.height = height
    contentInset.bottom += height

    loaderView.stopAnimating()
    infiniteScrollingLoader = loaderView
    infiniteScrollingDelegate = delegate
    addSubview(loaderView)
    updateInfiniteLoaderPosition()
    infiniteScrollingState = .stopped
  }

  public func removeInfiniteScrolling() {
    if let loader = infiniteScrollingLoader {
      contentInset.bottom -= loader.bounds.height
      loader.removeFromSuperview()
      infiniteScrollingLoader = nil
    }
    infiniteScrollingDelegate = nil
    infiniteScrollingState = .stopped
  }

  open override var contentSize: CGSize {
    didSet { updateInfiniteLoaderPosition() }
  }

  // MARK: Fileprivate

  fileprivate let epoxyDataSource: CollectionViewEpoxyDataSource

  // MARK: Private

  private var queuedUpdate: (
    newData: InternalCollectionViewEpoxyData?,
    animated: Bool,
    changesetMaker: (InternalCollectionViewEpoxyData?) -> EpoxyChangeset?)?

  private var isUpdating = false
  private var infiniteScrollingLoader: (UIView & Animatable)?
  private weak var infiniteScrollingDelegate: InfiniteScrollingDelegate?
  private var infiniteScrollingState: InfiniteScrollingState = .stopped
  private var ephemeralStateCache = [String: RestorableState?]()

  private func setUp() {
    // There are rendering issues in iOS 10 when using self-sizing supplementary views
    // when prefetching is enabled.
    // There are also self sizing invalidation issues in iOS 10 and iOS 11 if prefetching is enabled.
    isPrefetchingEnabled = false

    delegate = self
    epoxyDataSource.epoxyInterface = self
    epoxyDataSource.reorderingDelegate = self
    dataSource = epoxyDataSource
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func configure(cell: Cell, with item: EpoxyableModel, animated: Bool) {
    let cellSelectionStyle = item.selectionStyle ?? selectionStyle
    switch cellSelectionStyle {
      case .noBackground:
        cell.selectedBackgroundColor = nil
      case .color(let selectionColor):
        cell.selectedBackgroundColor = selectionColor
      }

    _ = item.configure(cell: cell, forTraitCollection: traitCollection, animated: animated)
    _ = item.setBehavior(cell: cell) // TODO(ls): make these items actually epoxy items
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

    guard animated,
      data != nil,
      let sectionCount = dataSource?.numberOfSections?(in: self),
      sectionCount > 0
      else {
        _ = changesetMaker(data)
        reloadData()
        completeUpdates()
        return
    }

    performBatchUpdates({
      self.animateUpdates(data: data, changesetMaker: changesetMaker)
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

  private func animateUpdates(
    data: InternalCollectionViewEpoxyData?,
    changesetMaker: @escaping (InternalCollectionViewEpoxyData?) -> EpoxyChangeset?)
  {
    guard let changeset = changesetMaker(data) else { return }

    changeset.itemChangeset.updates.forEach { fromIndexPath, toIndexPath in
      if let cell = self.cellForItem(at: fromIndexPath as IndexPath) as? CollectionViewCell,
        let epoxyItem = self.epoxyDataSource.epoxyItem(at: toIndexPath) {
        epoxyItem.configure(cell: cell, forTraitCollection: traitCollection, animated: true)
        epoxyItem.configure(cell: cell, forTraitCollection: traitCollection, state: cell.state)
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
        assertionFailure("Only CollectionViewCell and subclasses are allowed in a CollectionView.")
        return
      }
      if let item = epoxyDataSource.epoxyItem(at: indexPath) {
        item.setBehavior(cell: cell)
      }
    }
  }

  private func completeUpdates() {
    resetBehaviors()
    isUpdating = false
  }

  private func updatedInfiniteScrollingState(in scrollView: UIScrollView) -> (InfiniteScrollingState, Bool) {
    let previousState = infiniteScrollingState
    let newState = previousState.next(in: scrollView)
    return (newState, previousState == .triggered && newState == .loading)
  }

  private func updateInfiniteLoaderPosition() {
    guard let infiniteScrollingLoader = infiniteScrollingLoader else { return }
    infiniteScrollingLoader.frame = CGRect(
      x: 0,
      y: contentSize.height,
      width: contentSize.width,
      height: infiniteScrollingLoader.bounds.height)
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
      let item = epoxyDataSource.epoxyItem(at: indexPath),
      let section = epoxyDataSource.epoxySection(at: indexPath.section) else {
      assertionFailure("Index path is out of bounds.")
      return
    }

    guard let cell = cell as? Cell else {
      assertionFailure("Cell does not match expected type CollectionView.Cell")
      return
    }

    guard let view = cell.view else {
      assertionFailure("Cell does not have an attached view")
      return
    }

    epoxyItemDisplayDelegate?.collectionView(self, willDisplayEpoxyModel: item, with: view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath)
  {
    guard
      let item = epoxyDataSource.epoxyItemIfPresent(at: indexPath),
      let section = epoxyDataSource.epoxySectionIfPresent(at: indexPath.section),
      let cell = cell as? Cell,
      let view = cell.view else { return }

    epoxyItemDisplayDelegate?.collectionView(self, didEndDisplayingEpoxyModel: item, with: view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplayingSupplementaryView view: UICollectionReusableView,
    forElementOfKind elementKind: String,
    at indexPath: IndexPath)
  {
    guard
      let section = epoxyDataSource.epoxySectionIfPresent(at: indexPath.section),
      let item = epoxyDataSource.supplementaryModelIfPresent(ofKind: elementKind, at: indexPath) else
    {
      return
    }

    epoxyItemDisplayDelegate?.collectionView(self, didEndDisplayingSupplementaryEpoxyModel: item, with: view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplaySupplementaryView view: UICollectionReusableView,
    forElementKind elementKind: String,
    at indexPath: IndexPath)
  {
    guard
      let section = epoxyDataSource.epoxySection(at: indexPath.section),
      let model = epoxyDataSource.supplementaryModelIfPresent(ofKind: elementKind, at: indexPath) else
    {
      assertionFailure(
        "Supplementary epoxy models not found for the given element kind and index path.")
      return
    }

    guard let view = view as? CollectionViewReusableView else {
      assertionFailure(
        "Supplementary view does not match expected type CollectionViewReusableView.")
      return
    }

    epoxyItemDisplayDelegate?.collectionView(
      self,
      willDisplaySupplementaryEpoxyModel: model,
      with: view,
      in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    shouldHighlightItemAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didHighlightItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        assertionFailure("Index path is out of bounds")
        return
    }
    item.configure(cell: cell, forTraitCollection: traitCollection, state: .highlighted)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didUnhighlightItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        return
    }
    item.configure(cell: cell, forTraitCollection: traitCollection, state: .normal)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    shouldSelectItemAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        assertionFailure("Index path is out of bounds")
        return
    }
    item.configure(cell: cell, forTraitCollection: traitCollection, state: .selected)
    item.didSelect(cell)

    if autoDeselectItems {
      // If collectionView modifications have been made, indexPath may no longer point to the correct
      // item so we find the all currently selected items and deselect them.
      // In practice this should always be a single item
      if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
        selectedIndexPaths.forEach { collectionView.deselectItem(at: $0, animated: true) }
      }
      _ = item.configure(cell: cell, forTraitCollection: traitCollection, state: .normal)
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    shouldDeselectItemAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        return
    }
    item.configure(cell: cell, forTraitCollection: traitCollection, state: .normal)
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
    let (newState, shouldTrigger) = updatedInfiniteScrollingState(in: scrollView)
    infiniteScrollingState = newState
    let delegateWantsInfiniteScrolling = infiniteScrollingDelegate?.shouldFireInfiniteScrolling() ?? true
    if shouldTrigger && delegateWantsInfiniteScrolling {
      infiniteScrollingLoader?.startAnimating()
      infiniteScrollingDelegate?.didScrollToInfiniteLoader { [weak self] in
        self?.infiniteScrollingLoader?.stopAnimating()
        self?.updateInfiniteLoaderPosition()
        self?.infiniteScrollingState = .stopped
      }
    } else if !delegateWantsInfiniteScrolling {
      infiniteScrollingState = .stopped
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
    return scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
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
    let models = indexPaths.compactMap(epoxyDataSource.epoxyItem(at:))
      .map { $0.epoxyModel }

    guard !models.isEmpty else { return }

    epoxyItemPrefetchDataSource?.collectionView(self, prefetch: models)
  }

  public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    let models = indexPaths.compactMap(epoxyDataSource.epoxyItem(at:))
      .map { $0.epoxyModel }

    guard !models.isEmpty else { return }

    epoxyItemPrefetchDataSource?.collectionView(self, cancelPrefetchingOf: models)
  }
}

// MARK: CollectionViewDataSourceReorderingDelegate

extension CollectionView: CollectionViewDataSourceReorderingDelegate {
  func dataSource(_ dataSource: CollectionViewEpoxyDataSource,
    moveItemWithDataID dataID: String,
    inSectionWithDataID fromSectionDataID: String,
    toSectionWithDataID toSectionDataID: String,
    withDestinationDataId destinationDataId: String)
  {
    reorderingDelegate?.collectionView(
      self, moveItemWithDataID: dataID,
      inSectionWithDataID: fromSectionDataID,
      toSectionWithDataID: toSectionDataID,
      withDestinationDataId: destinationDataId)
  }
}
