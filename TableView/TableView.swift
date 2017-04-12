//  Created by Laura Skelton on 11/28/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// The behavior of the TableView on update.
///
/// - Diffs: The TableView animates row inserts, deletes, moves, and updates.
/// - Reloads: The TableView reloads completely.
public enum TableViewUpdateBehavior {
  case Diffs
  case Reloads
}

/// A TableView class that handles updates through its `setStructure` method, and optionally animates diffs.
public final class TableView: UITableView {

  // MARK: Lifecycle

  /// Initializes the TableView and configures its behavior on update.
  ///
  /// - Parameters:
  ///     - updateBehavior: Use `.Diffs` if you want the TableView to animate changes through inserts, deletes, moves, and updates. Use `.Reloads` if you want the TableView to completely reload when the Structure is set.
  public init(updateBehavior: TableViewUpdateBehavior) {
    self.updateBehavior = updateBehavior
    super.init(frame: .zero, style: .plain)
    setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// Delegate for handling `UIScrollViewDelegate` callbacks related to scrolling.
  /// Ignores zooming delegate methods.
  public weak var scrollDelegate: UIScrollViewDelegate?

  /// Delegate which indicates when a list item will be displayed, typically used
  /// for logging.
  public weak var listItemDisplayDelegate: TableViewListItemDisplayDelegate?

  /// Selection style for the `UITableViewCell`s of `ListItem`s that have `isSelectable == true`
  public var selectionStyle: UITableViewCellSelectionStyle = .default

  /// Sets the TableView's data. By default, this will diff the new `ListStructure` against the
  /// existing `ListStructure` and animate the changes to the TableView.
  /// Set `shouldDiff` to `false` if you want the TableView to do a full reload with the new content.
  ///
  /// - Parameters:
  ///     - structure: The `ListStructure` instance representing the TableView's data.
  public func setStructure(_ structure: ListStructure?) {

    // TODO(ls): Add repeated calls to queue

    var newInternalStructure: ListInternalTableViewStructure?
    if let structure = structure {
      let internalStructure = ListInternalTableViewStructure.make(with: structure)
      registerReuseIDs(with: internalStructure)
      newInternalStructure = internalStructure
    }

    guard let oldStructure = self.structure,
      let newStructure = newInternalStructure else {

        self.structure = newInternalStructure
        reloadData()
        return
    }

    self.structure = newStructure

    switch updateBehavior {
    case .Diffs:
      let changeset = newStructure.makeChangeset(from: oldStructure)
      apply(changeset)
    case .Reloads:
      reloadData()
    }
  }

  /// Sets the `ViewMaker` to use for the dividers between rows.
  ///
  /// - Parameters:
  ///     - viewMaker: Block that should return an initialized view of the type you'd like to use for this divider.
  public func setDividerViewMaker(viewMaker: @escaping ViewMaker) {
    rowDividerViewMaker = viewMaker
  }

  /// Sets the `ViewMaker` to use for the dividers between a section header and its rows.
  ///
  /// - Parameters:
  ///     - viewMaker: Block that should return an initialized view of the type you'd like to use for this divider.
  public func setSectionHeaderDividerViewMaker(viewMaker: @escaping ViewMaker) {
    sectionHeaderDividerViewMaker = viewMaker
  }
  
  public override func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering cell classes on a TableView. Use registerReuseID:viewMaker:viewConfigurer instead.")
  }

  public override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering cell nibs on a TableView. Use registerReuseID:viewMaker:viewConfigurer instead.")
  }

  public override func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering header or footer nibs on a TableView. Use registerReuseID:viewMaker:viewConfigurer instead.")
  }

  public override func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering header or footer classes on a TableView. Use registerReuseID:viewMaker:viewConfigurer instead.")
  }

  // MARK: Fileprivate

  fileprivate let updateBehavior: TableViewUpdateBehavior
  fileprivate var structure: ListInternalTableViewStructure?

  fileprivate var rowDividerViewMaker: ViewMaker?
  fileprivate var sectionHeaderDividerViewMaker: ViewMaker?
  fileprivate var reuseIDs = Set<String>()

  fileprivate func setUp() {
    delegate = self
    dataSource = self
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = 44 // TODO(ls): Use better estimated height
    allowsSelection = false // Handle selection in subviews if desired
    separatorStyle = .none
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = false
  }

  fileprivate func registerReuseIDs(with listStructure: ListInternalTableViewStructure) {

    var newReuseIDs = Set<String>()
    listStructure.sections.forEach { section in
      section.items.forEach { item in
        newReuseIDs.insert(item.listItem.reuseID)
      }
    }

    reuseIDs.forEach { reuseID in
      if !newReuseIDs.contains(reuseID) {
        unregister(reuseID: reuseID)
      }
    }

    newReuseIDs.forEach { reuseID in
      if !reuseIDs.contains(reuseID) {
        register(reuseID: reuseID)
      }
    }

    reuseIDs = newReuseIDs
  }

  fileprivate func register(reuseID: String) {
    super.register(TableViewCell.self,
                   forCellReuseIdentifier: reuseID)
  }

  fileprivate func unregister(reuseID: String) {
    super.register((nil as AnyClass?),
                   forCellReuseIdentifier: reuseID)
  }

  fileprivate func listItem(at indexPath: IndexPath) -> ListInternalTableViewItemStructure? {
    guard let structure = structure else {
      assert(false, "Can't load list item with nil structure")
      return nil
    }

    if structure.sections.count < indexPath.section + 1 {
      return nil
    }

    let section = structure.sections[indexPath.section]

    if section.items.count < indexPath.row + 1 {
      return nil
    }

    return section.items[indexPath.row]
  }

  fileprivate func updateDivider(for cell: TableViewCell, dividerType: ListItemDividerType) {
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

  fileprivate func apply(_ changeset: ListInternalTableViewStructureChangeset) {

    beginUpdates()

    changeset.itemChangeset.updates.forEach { fromIndexPath, toIndexPath in
      if let cell = cellForRow(at: fromIndexPath as IndexPath) as? TableViewCell,
        let listItem = listItem(at: toIndexPath)?.listItem {
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
      if let item = listItem(at: indexPath) {
        self.updateDivider(for: cell, dividerType: item.dividerType)
      }
    }
  }
}

// MARK: UITableViewDataSource

extension TableView: UITableViewDataSource {

  public func numberOfSections(in tableView: UITableView) -> Int {
    guard let structure = structure else { return 0 }

    return structure.sections.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let structure = structure else { return 0 }

    return structure.sections[section].items.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let item = listItem(at: indexPath) else {
      assert(false, "Index path is out of bounds.")
      return UITableViewCell(style: .default, reuseIdentifier: "")
    }
    
    let cell = tableView.dequeueReusableCell(
      withIdentifier: item.listItem.reuseID,
      for: indexPath)

    cell.selectionStyle = selectionStyle

    if let cell = cell as? TableViewCell {
      item.listItem.configure(cell: cell, animated: false)
      updateDivider(for: cell, dividerType: item.dividerType)
    } else {
      assert(false, "Only TableViewCell and subclasses are allowed in a TableView.")
    }
    return cell
  }
}

// MARK: UITableViewDelegate

extension TableView: UITableViewDelegate {

  public func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath)
  {
    guard let item = listItem(at: indexPath) else {
      assert(false, "Index path is out of bounds.")
      return
    }
    listItemDisplayDelegate?.tableView(self, willDisplay: item.listItem)
  }

  public func tableView(
    _ tableView: UITableView,
    shouldHighlightRowAt indexPath: IndexPath) -> Bool
  {
    guard let item = listItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return false
    }
    return item.listItem.isSelectable
  }

  public func tableView(
    _ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath?
  {
    guard let item = listItem(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return nil
    }
    return item.listItem.isSelectable ? indexPath : nil
  }

  public func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath)
  {
    guard let item = listItem(at: indexPath) else {
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

extension TableView: ListInterface {
  
}
