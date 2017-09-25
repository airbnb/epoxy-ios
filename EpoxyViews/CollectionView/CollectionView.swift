//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// A `UICollectionView` class that handles updates through its `setSections` method, and optionally animates diffs.
public class CollectionView: UICollectionView,
  EpoxyInterface,
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

  public func setSections(_ sections: [EpoxyCollectionViewSection]?, animated: Bool) {
    epoxyDataSource.setSections(sections, animated: animated)
  }

  public func scrollToItem(at dataID: String, position: UICollectionViewScrollPosition = .centeredVertically, animated: Bool = false) {
    if let indexPath = epoxyDataSource.internalData?.indexPathForItem(at: dataID) {
      scrollToItem(at: indexPath, at: position, animated: animated)
    }
  }

  public func updateItem(
    at dataID: String,
    with item: EpoxyableModel,
    animated: Bool)
  {
    epoxyDataSource.updateItem(at: dataID, with: item, animated: animated)
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

  /// The delegate that builds transition layouts.
  public weak var transitionLayoutDelegate: CollectionViewTransitionLayoutDelegate?

  public var visibleIndexPaths: [IndexPath] {
    return indexPathsForVisibleItems
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

  public func configure(cell: Cell, with item: DataType.Item) {
    configure(cell: cell, with: item, animated: false)
  }

  public func configure(supplementaryView: CollectionViewReusableView, with model: SupplementaryViewEpoxyableModel) {
    model.configure(reusableView: supplementaryView)
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
    // queue new data, replace old queued data instead of additive
    guard !isUpdating else {
      queuedUpdate = (
        newData: newData,
        animated: animated,
        changesetMaker: changesetMaker)
      return
    }

    updateView(with: newData, animated: animated, changesetMaker: changesetMaker)
  }

  /// Convert an index path to a dataID, only for use in collection view layout delegate methods
  public func dataIDForItem(at indexPath: IndexPath) -> String? {
    return epoxyDataSource.epoxyItem(at: indexPath)?.dataID
  }

  /// Convert a section index to a dataID, only for use in collection view layout delegate methods
  public func dataIDForSection(at index: Int) -> String? {
    return epoxyDataSource.epoxySection(at: index)?.dataID
  }

  // MARK: Fileprivate

  fileprivate let epoxyDataSource: CollectionViewEpoxyDataSource

  // MARK: Private

  private var queuedUpdate: (
    newData: InternalCollectionViewEpoxyData?,
    animated: Bool,
    changesetMaker: (InternalCollectionViewEpoxyData?) -> EpoxyChangeset?)?

  private var isUpdating = false

  private func setUp() {
    delegate = self
    epoxyDataSource.epoxyInterface = self
    dataSource = epoxyDataSource
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func configure(cell: Cell, with item: EpoxyableModel, animated: Bool) {
    item.configure(cell: cell, animated: animated)
    item.setBehavior(cell: cell) // TODO(ls): make these items actually epoxy items
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
      if let nextUpdate = self.queuedUpdate {
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
        epoxyItem.configure(cell: cell, animated: true)
        epoxyItem.configure(cell: cell, forState: cell.state)
      }
    }

    // TODO(ls): Make animations configurable

    deleteSections(changeset.sectionChangeset.deletes as IndexSet)
    deleteItems(at: changeset.itemChangeset.deletes)

    changeset.sectionChangeset.moves.forEach { (fromIndex, toIndex) in
      moveSection(fromIndex, toSection: toIndex)
    }

    changeset.itemChangeset.moves.forEach { (fromIndexPath, toIndexPath) in
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

  // MARK: UICollectionViewDelegate

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds.")
      return
    }
    epoxyItemDisplayDelegate?.collectionView(self, willDisplay: item)
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
    item.configure(cell: cell, forState: .highlighted)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didUnhighlightItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        assertionFailure("Index path is out of bounds")
        return
    }
    item.configure(cell: cell, forState: .normal)
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
    item.configure(cell: cell, forState: .selected)
    item.didSelect(cell)

    collectionView.deselectItem(at: indexPath, animated: true)
    item.configure(cell: cell, forState: .normal)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyItem(at: indexPath),
      let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
        assertionFailure("Index path is out of bounds")
        return
    }
    item.configure(cell: cell, forState: .normal)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
    newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
  {
    guard let delegate = transitionLayoutDelegate else {
      return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
    return delegate.collectionView(collectionView, transitionLayoutForOldLayout: fromLayout, newLayout:toLayout)
  }

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScroll?(scrollView)
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
  public override func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
    super.register(cellClass, forCellWithReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering cell nibs on a CollectionView. The CollectionViewEpoxyDataSource handles this for you.")
  public override func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
    super.register(nib, forCellWithReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering supplementary view nibs on a CollectionView. The CollectionViewEpoxyDataSource handles this for you.")
  public override func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
    super.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering supplementary view classes on a CollectionView. The CollectionViewEpoxyDataSource handles this for you.")
  public override func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
    super.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
  }

}
