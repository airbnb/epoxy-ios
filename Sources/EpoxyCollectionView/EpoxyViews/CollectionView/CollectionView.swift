//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

/// A `UICollectionView` class that handles updates through its `setSections` method, and optionally
/// animates diffs.
open class CollectionView: UICollectionView {

  // MARK: Lifecycle

  public init(collectionViewLayout: UICollectionViewLayout) {
    epoxyDataSource = CollectionViewEpoxyDataSource()
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
        self.invalidateLayout()
      }
    }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()

    if window == nil {
      scrollToItemHelper.cancelAnimatedScrollToItem()
    }
  }

  // MARK: Public

  public func setSections(_ sections: [SectionModel], animated: Bool) {
    EpoxyLogger.shared.assert(Thread.isMainThread, "This method must be called on the main thread.")
    epoxyDataSource.registerSections(sections)
    apply(.make(sections: sections), animated: animated)
  }

  public func scrollToItem(at path: ItemPath, animated: Bool = false) {
    scrollToItem(at: path, position: .centeredVertically, animated: animated)
  }

  public func scrollToItem(at path: ItemPath, position: ScrollPosition, animated: Bool) {
    guard let indexPath = indexPathForItem(at: path) else { return }

    if GlobalEpoxyConfig.shared.usesAccurateScrollToItem {
      scrollToItemHelper.accuratelyScrollToItem(
        at: indexPath,
        position: position,
        animated: animated)
    } else {
      scrollToItem(at: indexPath, at: position, animated: animated)
    }
  }

  /// Sets a given item view as the first responder.
  ///
  /// The view must be visible at the time this method is called, so you should call
  /// `scrollToItem(at:)` before calling this method if necessary. The view should also be set up to
  /// properly react to `becomeFirstResponder()` being called on it.
  ///
  /// - Parameter path: The path to the item view you want to become the first responder.
  public func setItemAsFirstResponder(at path: ItemPath) {
    guard
      let indexPath = indexPathForItem(at: path),
      let cell = cellForItem(at: indexPath) as? CollectionViewCell
    else {
      EpoxyLogger.shared.assertionFailure("Tried to become first responder for a cell that was not visible.")
      return
    }
    cell.view?.becomeFirstResponder()
  }

  public func moveAccessibilityFocusToItem(
    at path: ItemPath,
    notification: UIAccessibility.Notification = .layoutChanged)
  {
    guard
      let indexPath = indexPathForItem(at: path),
      let cell = cellForItem(at: indexPath) as? CollectionViewCell
    else {
      EpoxyLogger.shared.assertionFailure("item not found")
      return
    }
    UIAccessibility.post(notification: notification, argument: cell)
  }

  public func moveAccessibilityFocusToLastFocusedElement() {
    guard let lastFocusedDataID = lastFocusedDataID else { return }
    moveAccessibilityFocusToItem(at: lastFocusedDataID)
  }

  public func invalidateLayout() {
    collectionViewLayout.invalidateLayout()
  }

  public func selectItem(at path: ItemPath, animated: Bool) {
    guard let indexPath = indexPathForItem(at: path) else {
      EpoxyLogger.shared.assertionFailure("item not found")
      return
    }
    selectItem(at: indexPath, animated: animated, scrollPosition: [])

    if
      let item = epoxyDataSource.data?.item(at: indexPath),
      let cell = cellForItem(at: indexPath) as? EpoxyCell
    {
      item.configureStateChange(
        in: cell,
        with: EpoxyViewMetadata(traitCollection: traitCollection, state: .selected, animated: animated))
    }
  }

  public func deselectItem(at path: ItemPath, animated: Bool) {
    guard let indexPath = indexPathForItem(at: path) else {
      return
    }
    deselectItem(at: indexPath, animated: animated)

    if
      let item = epoxyDataSource.data?.item(at: indexPath),
      let cell = cellForItem(at: indexPath) as? EpoxyCell
    {
      item.configureStateChange(
        in: cell,
        with: EpoxyViewMetadata(traitCollection: traitCollection, state: .normal, animated: animated))
    }
  }

  /// Returns the current model for the section with the given `dataID` if it exists, else `nil`.
  public func section(at dataID: AnyHashable) -> SectionModel? {
    guard let sectionIndex = epoxyDataSource.data?.indexForSection(at: dataID) else {
      return nil
    }
    return epoxyDataSource.data?.section(at: sectionIndex)
  }

  /// Returns the current model for the item with the given `path` if it exists, else `nil`.
  public func item(at path: ItemPath) -> AnyItemModel? {
    guard let indexPath = epoxyDataSource.data?.indexPathForItem(at: path) else {
      return nil
    }
    return epoxyDataSource.data?.item(at: indexPath)
  }

  /// Convert an `ItemPath` to an `IndexPath`, only for use in collection view layout delegate
  /// methods.
  public func indexPathForItem(at path: ItemPath) -> IndexPath? {
    epoxyDataSource.data?.indexPathForItem(at: path)
  }

  /// Convert an `IndexPath` to an `AnyItemModel`, only for use in collection view layout delegate
  /// methods.
  public func item(at indexPath: IndexPath) -> AnyItemModel? {
    epoxyDataSource.data?.item(at: indexPath)
  }

  /// Convert an `IndexPath` to its corresponding `ItemPath` if a valid item and section exists at
  /// the given `indexPath`, otherwise returns `nil`.
  public func path(for indexPath: IndexPath) -> ItemPath? {
    guard
      let itemID = epoxyDataSource.data?.item(at: indexPath)?.dataID,
      let sectionID = epoxyDataSource.data?.section(at: indexPath.section)?.dataID
    else {
      return nil
    }
    return .init(itemDataID: itemID, sectionDataID: sectionID)
  }

  public func item(at point: CGPoint) -> AnyItemModel? {
    guard
      let indexPath = indexPathForItem(at: point),
      let item = epoxyDataSource.data?.item(at: indexPath)
    else {
      return nil
    }
    return item
  }

  /// Convert a section index to a `SectionModel`, only for use in collection view layout delegate
  /// methods.
  public func section(at index: Int) -> SectionModel? {
    return epoxyDataSource.data?.section(at: index)
  }

  /// Reconfigures the item at the given `indexPath`.
  public func reloadItem(at indexPath: IndexPath, animated: Bool) {
    guard
      let cell = cellForItem(at: indexPath as IndexPath) as? CollectionViewCell,
      let item = epoxyDataSource.data?.item(at: indexPath)
    else {
      return
    }

    configure(cell: cell, with: item, animated: animated)
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
        guard let item = self?.epoxyDataSource.data?.item(at: indexPath) else {
          EpoxyLogger.shared.assertionFailure("model not found")
          return nil
        }
        return VisibleItemMetadata(model: item, view: cell.view)
      }

      guard let section = epoxyDataSource.data?.section(at: section) else {
        EpoxyLogger.shared.assertionFailure("section not found")
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

  // MARK: Internal

  func register(cellReuseID: String) {
    super.register(CollectionViewCell.self, forCellWithReuseIdentifier: cellReuseID)
  }

  func register(supplementaryViewReuseID: String, forKind elementKind: String) {
    super.register(
      CollectionViewReusableView.self,
      forSupplementaryViewOfKind: elementKind,
      withReuseIdentifier: supplementaryViewReuseID)
  }

  func configure(cell: CollectionViewCell, with item: AnyItemModel, animated: Bool) {
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

  func configure(
    supplementaryView: CollectionViewReusableView,
    with model: AnySupplementaryItemModel,
    animated: Bool)
  {
    model.configure(
      reusableView: supplementaryView,
      traitCollection: traitCollection,
      animated: animated)
    model.setBehavior(
      reusableView: supplementaryView,
      traitCollection: traitCollection,
      animated: animated)
  }

  func apply(_ newData: InternalCollectionViewEpoxyData, animated: Bool) {
    guard !updateState.isUpdating else {
      queuedUpdate = (newData: newData, animated: animated)
      return
    }

    updateView(with: newData, animated: animated)
  }

  // MARK: Private

  /// The state of an data update.
  private enum UpdateState {
    /// No data update is in progress.
    case notUpdating
    /// A data update is being prepared to be applied.
    case preparingUpdate
    /// A data update is being applied from the given previous data.
    case updating(from: InternalCollectionViewEpoxyData)

    /// Whether a data update is in progress.
    var isUpdating: Bool {
      switch self {
      case .notUpdating:
        return false
      case .preparingUpdate, .updating:
        return true
      }
    }
  }

  /// An identifier used to track the items that are visible in a section.
  private enum SectionVisibleItemID: Hashable {
    case item(dataID: AnyHashable)
    case supplementaryItem(elementKind: String, dataID: AnyHashable)
  }

  private let epoxyDataSource: CollectionViewEpoxyDataSource

  private var queuedUpdate: (newData: InternalCollectionViewEpoxyData, animated: Bool)?

  private var updateState = UpdateState.notUpdating
  private var ephemeralStateCache = [AnyHashable: RestorableState?]()
  private var lastFocusedDataID: ItemPath?

  /// A dictionary used to track visible sections, keyed by `SectionModel.dataID` and with a value
  /// of the `Set` of visible items in that section, else an empty `Set` or `nil` if there are none.
  private var visibleSectionItems = [AnyHashable: Set<SectionVisibleItemID>]()

  private lazy var scrollToItemHelper = CollectionViewScrollToItemHelper(collectionView: self)

  private func setUp() {
    isPrefetchingEnabled = GlobalEpoxyConfig.shared.usesCellPrefetching

    delegate = self
    epoxyDataSource.collectionView = self
    epoxyDataSource.reorderingDelegate = self
    dataSource = epoxyDataSource
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func updateView(with data: InternalCollectionViewEpoxyData, animated: Bool) {
    updateState = .preparingUpdate

    let performUpdates = {
      self.performBatchUpdates({
        self.performUpdates(data: data, animated: animated)
      }, completion: { _ in
        if let nextUpdate = self.queuedUpdate, self.window != nil {
          self.queuedUpdate = nil
          self.updateView(with: nextUpdate.newData, animated: nextUpdate.animated)
        } else {
          self.completeUpdates()
        }
      })
    }

    if GlobalEpoxyConfig.shared.usesBatchUpdatesForAllReloads {
      if animated {
        performUpdates()
      } else {
        UIView.performWithoutAnimation {
          performUpdates()
        }
      }
    } else {
      guard
        animated,
        let sectionCount = dataSource?.numberOfSections?(in: self),
        sectionCount > 0
      else {
        if let result = epoxyDataSource.applyData(data) {
          updateState = .updating(from: result.oldData)
        }
        reloadData()
        completeUpdates()
        return
      }

      performUpdates()
    }
  }

  private func performUpdates(data: InternalCollectionViewEpoxyData, animated: Bool) {
    guard let result = epoxyDataSource.applyData(data) else { return }
    updateState = .updating(from: result.oldData)

    for (fromIndexPath, toIndexPath) in result.changeset.itemChangeset.updates {
      if
        let cell = cellForItem(at: fromIndexPath) as? CollectionViewCell,
        let item = epoxyDataSource.data?.item(at: toIndexPath)
      {
        let metadata = EpoxyViewMetadata(
          traitCollection: traitCollection,
          state: cell.state,
          animated: animated)
        item.configure(cell: cell, with: metadata)
        item.configureStateChange(in: cell, with: metadata)
      }
    }

    for (elementKind, changeset) in result.changeset.supplementaryItemChangeset {
      for (fromIndexPath, toIndexPath) in changeset.updates {
        if
          let reusableView = supplementaryView(forElementKind: elementKind, at: fromIndexPath) as? CollectionViewReusableView,
          let item = epoxyDataSource.data?.supplementaryItem(ofKind: elementKind, at: toIndexPath)
        {
          item.configure(reusableView: reusableView, traitCollection: traitCollection, animated: animated)
        }
      }

      // TODO: It seems there's no way to handle deletes/inserts/moves of supplementary items as
      // there's no way to instruct a collection view to reload an existing supplementary item with
      // a different reuse ID without reloading the entire section.
    }

    deleteSections(result.changeset.sectionChangeset.deletes)
    deleteItems(at: result.changeset.itemChangeset.deletes)

    for (fromIndex, toIndex) in result.changeset.sectionChangeset.moves {
      moveSection(fromIndex, toSection: toIndex)
    }

    for (fromIndexPath, toIndexPath) in result.changeset.itemChangeset.moves {
      moveItem(at: fromIndexPath, to: toIndexPath)
    }

    insertSections(result.changeset.sectionChangeset.inserts)
    insertItems(at: result.changeset.itemChangeset.inserts)
  }

  private func resetBehaviors() {
    for indexPath in indexPathsForVisibleItems {
      guard let cell = cellForItem(at: indexPath) as? CollectionViewCell else {
        EpoxyLogger.shared.assertionFailure(
          "Only CollectionViewCell and subclasses are allowed in a CollectionView.")
        return
      }
      if let item = epoxyDataSource.data?.item(at: indexPath) {
        item.setBehavior(
          cell: cell,
          with: EpoxyViewMetadata(traitCollection: traitCollection, state: cell.state, animated: false))
      }
    }
  }

  private func completeUpdates() {
    resetBehaviors()
    updateState = .notUpdating
  }

  @objc
  private func didTriggerPullToRefreshControl(sender: UIRefreshControl) {
    didTriggerPullToRefresh?(sender)
  }

  /// Tracks whether the given `section` will display by determining if the given appearing `item`
  /// is its first visible `item`.
  private func handleSection(_ section: SectionModel, itemWillDisplay item: SectionVisibleItemID) {
    let previouslyNotVisible = visibleSectionItems[section.dataID, default: []].isEmpty
    visibleSectionItems[section.dataID, default: []].insert(item)
    if previouslyNotVisible {
      section.willDisplay?(())
    }
  }

  /// Tracks whether the given `section` did end displaying by determining if the given disappearing
  /// `item` its last visible `item`.
  private func handleSection(_ section: SectionModel, itemDidEndDisplaying item: SectionVisibleItemID) {
    visibleSectionItems[section.dataID, default: []].remove(item)
    let notVisible = visibleSectionItems[section.dataID, default: []].isEmpty
    if notVisible {
      section.didEndDisplaying?(())
    }
  }

}

// MARK: UIScrollViewDelegate

extension CollectionView: UIScrollViewDelegate {

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScroll?(scrollView)

    // Allow the programmatic scroll-to-item to be interrupted / cancelled if the user tries to
    // scroll.
    let isUserInitiatedScrolling = scrollView.isDragging && scrollView.isTracking
    if isUserInitiatedScrolling {
      scrollToItemHelper.cancelAnimatedScrollToItem()
    }
  }

  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
  }

  public func scrollViewWillEndDragging(
    _ scrollView: UIScrollView,
    withVelocity velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    scrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }

  public func scrollViewDidEndDragging(
    _ scrollView: UIScrollView,
    willDecelerate decelerate: Bool)
  {
    scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
  }

  public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    let shouldScrollToTop = scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true

    if shouldScrollToTop {
      scrollToItemHelper.cancelAnimatedScrollToItem()
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

}

// MARK: UICollectionViewDelegate

extension CollectionView: UICollectionViewDelegate {

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath)
  {
    guard
      let item = epoxyDataSource.data?.item(at: indexPath),
      let section = epoxyDataSource.data?.section(at: indexPath.section)
    else {
      return
    }

    handleSection(section, itemWillDisplay: .item(dataID: item.dataID))

    guard let cell = cell as? CollectionViewCell else {
      EpoxyLogger.shared.assertionFailure("Cell does not match expected type CollectionViewCell.")
      return
    }

    item.handleWillDisplay(cell, with: .init(traitCollection: traitCollection, state: cell.state, animated: false))
    (cell.view as? DisplayResponder)?.didDisplay(true)
    displayDelegate?.collectionView(self, willDisplayItem: item, with: cell.view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath)
  {
    // When updating, items ending display correspond to items in the old data.
    let data: InternalCollectionViewEpoxyData?
    switch updateState {
    case .notUpdating, .preparingUpdate:
      data = epoxyDataSource.data
    case .updating(from: let oldData):
      data = oldData
    }

    guard
      let item = data?.itemIfPresent(at: indexPath),
      let section = data?.sectionIfPresent(at: indexPath.section)
    else {
      return
    }

    handleSection(section, itemDidEndDisplaying: .item(dataID: item.dataID))

    guard let cell = cell as? CollectionViewCell else {
      EpoxyLogger.shared.assertionFailure("Cell does not match expected type CollectionViewCell.")
      return
    }

    item.handleDidEndDisplaying(cell, with: .init(traitCollection: traitCollection, state: cell.state, animated: false))
    (cell.view as? DisplayResponder)?.didDisplay(false)
    displayDelegate?.collectionView(self, didEndDisplayingItem: item, with: cell.view, in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplaySupplementaryView view: UICollectionReusableView,
    forElementKind elementKind: String,
    at indexPath: IndexPath)
  {
    // We don't assert since `UICollectionViewCompositionalLayout` can create and configure its own
    // supplementary views e.g. with a `.list(using: .init(appearance: .plain))` config.
    guard
      let section = epoxyDataSource.data?.sectionIfPresent(at: indexPath.section),
      let item = epoxyDataSource.data?.supplementaryItemIfPresent(ofKind: elementKind, at: indexPath)
    else {
      return
    }

    handleSection(
      section,
      itemWillDisplay: .supplementaryItem(elementKind: elementKind, dataID: item.dataID))

    guard let view = view as? CollectionViewReusableView else {
      EpoxyLogger.shared.assertionFailure(
        "Supplementary view does not match expected type CollectionViewReusableView.")
      return
    }

    item.handleWillDisplay(view, traitCollection: traitCollection, animated: false)

    (view.view as? DisplayResponder)?.didDisplay(true)

    displayDelegate?.collectionView(
      self,
      willDisplaySupplementaryItem: item,
      forElementKind: elementKind,
      with: view.view,
      in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplayingSupplementaryView view: UICollectionReusableView,
    forElementOfKind elementKind: String,
    at indexPath: IndexPath)
  {
    // When updating, items ending display correspond to items in the old data.
    let data: InternalCollectionViewEpoxyData?
    switch updateState {
    case .notUpdating, .preparingUpdate:
      data = epoxyDataSource.data
    case .updating(from: let oldData):
      data = oldData
    }

    // We don't assert since `UICollectionViewCompositionalLayout` can create and configure its own
    // supplementary views e.g. with a `.list(using: .init(appearance: .plain))` config.
    guard
      let section = data?.sectionIfPresent(at: indexPath.section),
      let item = data?.supplementaryItemIfPresent(ofKind: elementKind, at: indexPath)
    else {
      return
    }

    handleSection(
      section,
      itemDidEndDisplaying: .supplementaryItem(elementKind: elementKind, dataID: item.dataID))

    guard let view = view as? CollectionViewReusableView else {
      EpoxyLogger.shared.assertionFailure(
        "Supplementary view does not match expected type CollectionViewReusableView.")
      return
    }

    item.handleDidEndDisplaying(view, traitCollection: traitCollection, animated: false)

    (view.view as? DisplayResponder)?.didDisplay(false)

    displayDelegate?.collectionView(
      self,
      didEndDisplayingSupplementaryItem: item,
      forElementKind: elementKind,
      with: view.view,
      in: section)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    shouldHighlightItemAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.data?.item(at: indexPath) else {
      EpoxyLogger.shared.assertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didHighlightItemAt indexPath: IndexPath)
  {
    guard
      let item = epoxyDataSource.data?.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
    else {
      EpoxyLogger.shared.assertionFailure("Index path is out of bounds")
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
    guard
      let item = epoxyDataSource.data?.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
    else {
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
    guard let item = epoxyDataSource.data?.item(at: indexPath) else {
      EpoxyLogger.shared.assertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath)
  {
    guard
      let item = epoxyDataSource.data?.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
    else {
      EpoxyLogger.shared.assertionFailure("Index path is out of bounds")
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
        for selectedIndexPath in selectedIndexPaths {
          collectionView.deselectItem(at: selectedIndexPath, animated: true)
        }
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
    guard let item = epoxyDataSource.data?.item(at: indexPath) else {
      EpoxyLogger.shared.assertionFailure("Index path is out of bounds")
      return false
    }
    return item.isSelectable
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath)
  {
    guard
      let item = epoxyDataSource.data?.item(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
    else {
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

}

// MARK: UICollectionViewDataSourcePrefetching

extension CollectionView: UICollectionViewDataSourcePrefetching {
  public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    let models = indexPaths.compactMap { epoxyDataSource.data?.item(at: $0) }

    guard !models.isEmpty else { return }

    prefetchDelegate?.collectionView(self, prefetch: models)
  }

  public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    let models = indexPaths.compactMap { epoxyDataSource.data?.item(at:$0) }

    guard !models.isEmpty else { return }

    prefetchDelegate?.collectionView(self, cancelPrefetchingOf: models)
  }
}

// MARK: CollectionViewDataSourceReorderingDelegate

extension CollectionView: CollectionViewDataSourceReorderingDelegate {
  func dataSource(
    _ dataSource: CollectionViewEpoxyDataSource,
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
    else {
      return
    }

    lastFocusedDataID = .init(itemDataID: model.dataID, sectionDataID: section.dataID)

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
    else {
      return
    }

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
      let model = epoxyDataSource.data?.item(at: indexPath)
    else {
      EpoxyLogger.shared.assertionFailure("item not found")
      return nil
    }
    return model
  }

  private func sectionForCell(_ cell: CollectionViewCell) -> SectionModel? {
    guard
      let indexPath = indexPath(for: cell),
      let section = epoxyDataSource.data?.section(at: indexPath.section)
    else {
      EpoxyLogger.shared.assertionFailure("item not found")
      return nil
    }
    return section
  }
}

// MARK: Unavailable Methods

extension CollectionView {
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
