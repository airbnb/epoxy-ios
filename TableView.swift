//  Created by Laura Skelton on 11/28/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

public typealias ViewMaker = () -> UIView
public typealias ListItemViewConfigurer = (UIView, ListItemId) -> Void
public typealias ListItemSelectionHandler = (ListItemId) -> Void


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
    super.init(frame: .zero, style: .Plain)
    translatesAutoresizingMaskIntoConstraints = false
    setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// Sets the TableView's data. By default, this will diff the new `ListStructure` against the
  /// existing `ListStructure` and animate the changes to the TableView.
  /// Set `shouldDiff` to `false` if you want the TableView to do a full reload with the new content.
  ///
  /// - Parameters:
  ///     - structure: The `ListStructure` instance representing the TableView's data.
  public func setStructure(structure: ListStructure?) {

    var newInternalStructure: ListInternalTableViewStructure?
    if let structure = structure {
     newInternalStructure = ListInternalTableViewStructure.makeWithListStructure(structure)
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
      let changeset = ListInternalTableViewStructure.diff(oldStructure: oldStructure, newStructure: newStructure)
      applyChangeset(changeset)
    case .Reloads:
      reloadData()
    }
  }

  /// Registers a `reuseId` for the table view. Use the `viewMaker` to return the view you'd like to
  /// use for this `reuseId`. Use the `viewConfigurer` to configure that view using the `dataId`
  /// for a particular row. Use the optional `selectionHandler` to handle selection for rows with
  /// this `reuseId`.
  ///
  /// - Parameters:
  ///     - reuseId: String identifier that is unique to this set of make/configure/select blocks.
  ///     - viewMaker: Block that should return an initialized view of the type you'd like to use for this `reuseId`.
  ///     - viewConfigurer: Block used to configure cells or section headers as they appear.
  ///     - selectionHandler: Optional block fired when a cell with this `reuseId` is selected.
  public func registerReuseId(
    reuseId: String, forViewMaker
    viewMaker: ViewMaker,
    viewConfigurer: ListItemViewConfigurer,
    selectionHandler: ListItemSelectionHandler? = nil)
  {
    registerCellForReuseId(reuseId)
    viewMakers[reuseId] = viewMaker
    listItemViewConfigurers[reuseId] = viewConfigurer
    listItemSelectionHandlers[reuseId] = selectionHandler
  }

  /// Sets the `ViewMaker` to use for the dividers between rows.

  ///
  /// - Parameters:
  ///     - viewMaker: Block that should return an initialized view of the type you'd like to use for this divider.
  public func setDividerViewMaker(viewMaker: ViewMaker) {
    rowDividerViewMaker = viewMaker
  }

  /// Sets the `ViewMaker` to use for the dividers between a section header and its rows.
  ///
  /// - Parameters:
  ///     - viewMaker: Block that should return an initialized view of the type you'd like to use for this divider.
  public func setSectionHeaderDividerViewMaker(viewMaker: ViewMaker) {
    sectionHeaderDividerViewMaker = viewMaker
  }

  public override func registerClass(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering cell classes on a TableView. Use registerReuseId:viewMaker:viewConfigurer instead.")
  }

  public override func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering cell nibs on a TableView. Use registerReuseId:viewMaker:viewConfigurer instead.")
  }

  public override func registerNib(nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering header or footer nibs on a TableView. Use registerReuseId:viewMaker:viewConfigurer instead.")
  }

  public override func registerClass(aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    assert(false, "You shouldn't be registering header or footer classes on a TableView. Use registerReuseId:viewMaker:viewConfigurer instead.")
  }

  // MARK: Private

  private let updateBehavior: TableViewUpdateBehavior
  private var structure: ListInternalTableViewStructure?

  private var rowDividerViewMaker: ViewMaker?
  private var sectionHeaderDividerViewMaker: ViewMaker?
  private var viewMakers = [String: ViewMaker]()
  private var listItemViewConfigurers = [String: ListItemViewConfigurer]()
  private var listItemSelectionHandlers = [String: ListItemSelectionHandler]()

  private func setUp() {
    delegate = self
    dataSource = self
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = 44
  }

  private func registerCellForReuseId(reuseId: String) {
    super.registerClass(TableViewCell.self,
                        forCellReuseIdentifier: reuseId)
  }

  private func listItemAtIndexPath(indexPath: NSIndexPath) -> ListInternalTableViewItemStructure {
    guard let structure = structure else {
      assert(false, "Can't load list item with nil structure")
      return ListInternalTableViewItemStructure(
        listItem: ListItemStructure(itemId: ListItemId(reuseId: "", dataId: "")),
        dividerType: .None)
    }
    return structure.sections[indexPath.section].items[indexPath.row]
  }

  private func updateDividerForCell(cell: TableViewCell, dividerType: ListItemDividerType) {
    switch dividerType {
    case .None:
      cell.dividerView?.hidden = true
    case .RowDivider:
      if let rowDividerViewMaker = rowDividerViewMaker {
        cell.dividerView?.hidden = false
        cell.makeDividerView(with: rowDividerViewMaker)
      }
    case .SectionHeaderDivider:
      if let sectionHeaderDividerViewMaker = sectionHeaderDividerViewMaker {
        cell.dividerView?.hidden = false
        cell.makeDividerView(with: sectionHeaderDividerViewMaker)
      }
    }
  }

  private func applyChangeset(changeset: ListInternalTableViewStructureChangeset) {

    beginUpdates()

    changeset.itemChangeset.updates.forEach { fromIndexPath, toIndexPath in
      if let cell = cellForRowAtIndexPath(fromIndexPath) as? TableViewCell,
        let view = cell.view {
        let itemId = listItemAtIndexPath(toIndexPath).listItem.itemId
        listItemViewConfigurers[itemId.reuseId]?(view, itemId)
      }
    }

    // TODO(ls): Make animations configurable
    deleteRowsAtIndexPaths(changeset.itemChangeset.deletes, withRowAnimation: .Fade)
    deleteSections(changeset.sectionChangeset.deletes, withRowAnimation: .Fade)

    insertRowsAtIndexPaths(changeset.itemChangeset.inserts, withRowAnimation: .Fade)
    insertSections(changeset.sectionChangeset.inserts, withRowAnimation: .Fade)

    changeset.sectionChangeset.moves.forEach { (fromIndex, toIndex) in
      moveSection(fromIndex, toSection: toIndex)
    }

    changeset.itemChangeset.moves.forEach { (fromIndexPath, toIndexPath) in
      moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
    }
    
    endUpdates()

    indexPathsForVisibleRows?.forEach { indexPath in
      guard let cell = cellForRowAtIndexPath(indexPath) as? TableViewCell else {
        assert(false, "Only TableViewCell and subclasses are allowed in a TableView.")
        return
      }
      let item = listItemAtIndexPath(indexPath)
      self.updateDividerForCell(cell, dividerType: item.dividerType)
    }
  }
}

// MARK: UITableViewDataSource

extension TableView: UITableViewDataSource {

  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    guard let structure = structure else { return 0 }

    return structure.sections.count
  }

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let structure = structure else { return 0 }

    return structure.sections[section].items.count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let item = listItemAtIndexPath(indexPath)
    let reuseId = item.listItem.itemId.reuseId
    let cell = tableView.dequeueReusableCellWithIdentifier(reuseId,
                                                           forIndexPath: indexPath)

    if let cell = cell as? TableViewCell {
      if let viewMaker = viewMakers[reuseId] {
        cell.makeView(with: viewMaker)
      }
      updateDividerForCell(cell, dividerType: item.dividerType)
      listItemViewConfigurers[item.listItem.itemId.reuseId]?(cell.view!, item.listItem.itemId)
    } else {
      assert(false, "Only TableViewCell and subclasses are allowed in a TableView.")
    }
    return cell
  }
}

// MARK: UITableViewDelegate

extension TableView: UITableViewDelegate {

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let structure = structure else { return }

    let item = structure.sections[indexPath.section].items[indexPath.row]
    listItemSelectionHandlers[item.listItem.itemId.reuseId]?(item.listItem.itemId)
  }
}
