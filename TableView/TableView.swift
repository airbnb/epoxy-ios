//  Created by Laura Skelton on 11/28/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// A TableView class that handles updates through its `setStructure` method, and optionally animates diffs.
public class TableView: UITableView, DiffableListInterface {

  public typealias Structure = ListInternalTableViewStructure
  public typealias Cell = TableViewCell

  // MARK: Lifecycle

  /// Initializes the TableView
  ///
  /// Warning: In most cases you should use the factory methods in TableView+DLS instead of directly
  /// initializing this. Otherwise you'll need to manually set up the data source.
  public init() {
    super.init(frame: .zero, style: .plain)
    setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// The data source must be an instance of TableViewListDataSource
  open override weak var dataSource: UITableViewDataSource? {
    didSet {
      guard let listDataSource = dataSource as? TableViewListDataSource else {
        assert(false, "TableView requires TableViewListDataSource as its data source.")
        return
      }
      self.listDataSource = listDataSource
    }
  }

  /// Delegate for handling `UIScrollViewDelegate` callbacks related to scrolling.
  /// Ignores zooming delegate methods.
  public weak var scrollDelegate: UIScrollViewDelegate?

  /// Delegate which indicates when a list item will be displayed, typically used
  /// for logging.
  public weak var listItemDisplayDelegate: TableViewListItemDisplayDelegate?

  /// Selection style for the `UITableViewCell`s of `ListItem`s that have `isSelectable == true`
  public var selectionStyle: UITableViewCellSelectionStyle = .default

  /// Optional data source which is retained by the TableView to preserve legacy built-in-data-source behavior
  public var retainedDataSource: TableViewListDataSource?

  /// Block that should return an initialized view of the type you'd like to use for this divider.
  public var rowDividerViewMaker: ViewMaker?

  /// Block that should return an initialized view of the type you'd like to use for this divider.
  public var sectionHeaderDividerViewMaker: ViewMaker?

  public var visibleTypedCells: [Cell] {
    return visibleCells.map { $0 as! Cell }
  }

  public func register(reuseID: String) {
    super.register(TableViewCell.self,
                   forCellReuseIdentifier: reuseID)
  }

  public func unregister(reuseID: String) {
    super.register((nil as AnyClass?),
                   forCellReuseIdentifier: reuseID)
  }

  public func configure(cell: Cell, with item: Structure.Item) {
    configure(cell: cell, with: item, animated: false)
    cell.selectionStyle = selectionStyle
  }

  public func reloadItem(at indexPath: IndexPath, animated: Bool) {
    if let cell = cellForRow(at: indexPath as IndexPath) as? TableViewCell,
      let item = listDataSource?.listItem(at: indexPath) {
      configure(cell: cell, with: item, animated: animated)
    }
  }

  public func apply(_ changeset: ListInternalTableViewStructureChangeset) {

    beginUpdates()

    changeset.itemChangeset.updates.forEach { fromIndexPath, toIndexPath in
      if let cell = cellForRow(at: fromIndexPath as IndexPath) as? TableViewCell,
        let listItem = listDataSource?.listItem(at: toIndexPath)?.listItem {
        listItem.configure(cell: cell, animated: true)
      }
    }

    // TODO(ls): Make animations configurable
    deleteRows(at: changeset.itemChangeset.deletes as [IndexPath], with: .fade)
    deleteSections(changeset.sectionChangeset.deletes as IndexSet, with: .fade)

    insertRows(at: changeset.itemChangeset.inserts, with: .fade)
    insertSections(changeset.sectionChangeset.inserts as IndexSet, with: .fade)

    changeset.sectionChangeset.moves.forEach { (fromIndex, toIndex) in
      moveSection(fromIndex, toSection: toIndex)
    }

    changeset.itemChangeset.moves.forEach { (fromIndexPath, toIndexPath) in
      moveRow(at: fromIndexPath, to: toIndexPath)
    }

    endUpdates()

    indexPathsForVisibleRows?.forEach { indexPath in
      guard let cell = cellForRow(at: indexPath) as? TableViewCell else {
        assert(false, "Only TableViewCell and subclasses are allowed in a TableView.")
        return
      }
      if let item = listDataSource?.listItem(at: indexPath) {
        self.updateDivider(for: cell, dividerType: item.dividerType)
      }
    }
  }

  @available (*, unavailable, message: "You shouldn't be registering cell classes on a TableView. The TableViewListDataSource handles this for you.")
  public override func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering cell classes on a TableView. The TableViewListDataSource handles this for you.")
  }

  @available (*, unavailable, message: "You shouldn't be registering cell nibs on a TableView. The TableViewListDataSource handles this for you.")
  public override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering cell nibs on a TableView. The TableViewListDataSource handles this for you.")
  }

  @available (*, unavailable, message: "You shouldn't be header or footer nibs on a TableView. The TableViewListDataSource handles this for you.")
  public override func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering header or footer nibs on a TableView. The TableViewListDataSource handles this for you.")
  }

  @available (*, unavailable, message: "You shouldn't be registering header or footer classes on a TableView. The TableViewListDataSource handles this for you.")
  public override func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering header or footer classes on a TableView. The TableViewListDataSource handles this for you.")
  }

  // MARK: Fileprivate

  fileprivate weak var listDataSource: TableViewListDataSource?

  // MARK: Private

  private func setUp() {
    delegate = self
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = 44 // TODO(ls): Use better estimated height
    separatorStyle = .none
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func configure(cell: Cell, with item: Structure.Item, animated: Bool) {
    item.listItem.configure(cell: cell, animated: animated)
    updateDivider(for: cell, dividerType: item.dividerType)
  }

  private func updateDivider(for cell: TableViewCell, dividerType: ListItemDividerType) {
    switch dividerType {
    case .none:
      cell.dividerView?.isHidden = true
    case .rowDivider:
      if let rowDividerViewMaker = rowDividerViewMaker {
        cell.dividerView?.isHidden = false
        cell.makeDividerViewIfNeeded(with: rowDividerViewMaker)
      } else {
        cell.dividerView?.isHidden = true
      }
    case .sectionHeaderDivider:
      if let sectionHeaderDividerViewMaker = sectionHeaderDividerViewMaker {
        cell.dividerView?.isHidden = false
        cell.makeDividerViewIfNeeded(with: sectionHeaderDividerViewMaker)
      } else {
        cell.dividerView?.isHidden = true
      }
    }
  }

}

// MARK: UITableViewDelegate

extension TableView: UITableViewDelegate {

  public func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath)
  {
    guard let item = listDataSource?.listItem(at: indexPath) else {
      assert(false, "Index path is out of bounds.")
      return
    }
    listItemDisplayDelegate?.tableView(self, willDisplay: item.listItem)
  }

  public func tableView(
    _ tableView: UITableView,
    shouldHighlightRowAt indexPath: IndexPath) -> Bool
  {
    guard let item = listDataSource?.listItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return false
    }
    return item.listItem.isSelectable
  }

  public func tableView(
    _ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath?
  {
    guard let item = listDataSource?.listItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return nil
    }
    return item.listItem.isSelectable ? indexPath : nil
  }

  public func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath)
  {
    guard let item = listDataSource?.listItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return
    }
    item.listItem.didSelect()
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
}

extension TableView {

  /// Temporary method to preserve legacy built-in-data-source behavior
  public func setStructure(_ structure: ListStructure?) {
    guard let retainedDataSource = retainedDataSource else {
      assert(false, "You must set the retainedDataSource to use this legacy built-in-data-source behavior.")
      return
    }
    retainedDataSource.setStructure(structure)
  }

  /// Temporary method to preserve legacy built-in-data-source behavior
  public func updateItem(
    at dataID: String,
    with item: ListItem,
    animated: Bool)
  {
    guard let retainedDataSource = retainedDataSource else {
      assert(false, "You must set the retainedDataSource to use this legacy built-in-data-source behavior.")
      return
    }
    retainedDataSource.updateItem(at: dataID, with: item, animated: animated)
  }

}
