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
    super.init(frame: .zero, style: .Plain)
    setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// Sets the TableView's data and optionally updates its cell configuration block
  /// and selection block. By default, this will diff the new `ListStructure` against the
  /// existing `ListStructure` and animate the changes to the TableView.
  /// Set `shouldDiff` to `false` if you want the TableView to do a full reload with the new content.
  ///
  /// - Parameters:
  ///     - structure: The `ListStructure` instance representing the TableView's data.
  ///     - configurationBlock: Optional block used to configure cells or section headers as they appear.
  ///     - selectionBlock: Optional block fired when a cell is selected.
  ///
  /// - Warning: The `configurationBlock` must be set at least once before the initial load.
  public func setStructure(structure: ListStructure?,
                           configurationBlock: ((UIView, ListItemId) -> Void)? = nil,
                           selectionBlock: ((ListItemId) -> Void)? = nil) {

    if let configurationBlock = configurationBlock {
      self.configurationBlock = configurationBlock
    }

    if let selectionBlock = selectionBlock {
      self.selectionBlock = selectionBlock
    }

    guard let oldStructure = self.structure,
      let newStructure = structure else {

        self.structure = structure
        reloadData()
        return
    }

    self.structure = newStructure

    switch updateBehavior {
    case .Diffs:
      let changeset = ListStructure.diffForTableView(oldStructure: oldStructure, newStructure: newStructure)
      applyChangeset(changeset)
    case .Reloads:
      reloadData()
    }
  }

  /// Registers a cell view class for reuse in the TableView.
  ///
  /// - Parameters:
  ///     - cellClass: Expects a `UITableViewCell` or subclass.
  ///     - forReuseId: A `reuseId` must be linked with only one cell class.
  public func registerCellClass(cellClass: AnyClass?, forReuseId reuseId: String) {
    registerClass(cellClass, forCellReuseIdentifier: reuseId)
  }

  /// Registers a section header view class for reuse in the TableView.
  ///
  /// - Parameters:
  ///     - sectionHeaderClass: Expects a `UITableViewCell` or subclass.
  ///     - forReuseId: A `reuseId` must be linked with only one section header class, and cannot be the same as a cell class `reuseId`.
  public func registerSectionHeaderClass(sectionHeaderClass: AnyClass?, forReuseId reuseId: String) {
    registerClass(sectionHeaderClass, forCellReuseIdentifier: reuseId)
  }

  // MARK: Private

  private let updateBehavior: TableViewUpdateBehavior
  private var structure: ListStructure?
  private var configurationBlock: ((UIView, ListItemId) -> Void)?
  private var selectionBlock: ((ListItemId) -> Void)?

  private func setUp() {
    delegate = self
    dataSource = self
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = 44
  }

  private func listItemAtIndexPath(indexPath: NSIndexPath) -> ListItemStructure {
    guard let structure = structure else { assert(false, "Can't load list item with nil structure") }

    // Note: Default UITableView section headers are "sticky" at the top of the page.
    // We don't want this behavior, so we are implementing our section headers as cells
    // in the UITableView implementation.

    let section = structure.sections[indexPath.section]

    var sectionHeaderOffset: Int = 0
    if let sectionHeader = section.sectionHeader {
      if indexPath.row == 0 {
        return sectionHeader
      }
      sectionHeaderOffset = 1
    }

    return structure.sections[indexPath.section].items[indexPath.row - sectionHeaderOffset]
  }

  private func itemCountForSection(section: Int) -> Int {
    guard let structure = structure else { return 0 }
    let section = structure.sections[section]
    let sectionHeaderCount = section.sectionHeader != nil ? 1 : 0
    return section.items.count + sectionHeaderCount
  }

  private func applyChangeset(changeset: ListStructureChangeset) {

    beginUpdates()

    changeset.itemChangeset.updates.forEach { fromIndexPath, toIndexPath in
      if let cell = cellForRowAtIndexPath(fromIndexPath) {
        let item = listItemAtIndexPath(toIndexPath)
        if let configurationBlock = configurationBlock {
          configurationBlock(cell, item.itemId)
        } else {
          assert(false, "The configuration block should be set before the tableview's initial load.")
        }
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
  }
}

// MARK: UITableViewDataSource

extension TableView: UITableViewDataSource {

  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    guard let structure = structure else { return 0 }

    return structure.sections.count
  }

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itemCountForSection(section)
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let item = listItemAtIndexPath(indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(item.itemId.reuseId,
                                                           forIndexPath: indexPath)
    if let configurationBlock = configurationBlock {
      configurationBlock(cell, item.itemId)
    } else {
      assert(false, "The configuration block should be set before the tableview's initial load.")
    }
    return cell
  }
}

// MARK: UITableViewDelegate

extension TableView: UITableViewDelegate {

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let structure = structure else { return }

    let item = structure.sections[indexPath.section].items[indexPath.row]
    selectionBlock?(item.itemId)
  }
}

extension ListStructure {
  public static func diffForTableView(oldStructure
    oldStructure: ListStructure,
    newStructure: ListStructure) -> ListStructureChangeset
  {
    let sectionChangeset = QuickDiff.diffIndexSets(
      oldArray: oldStructure.sections,
      newArray: newStructure.sections)

    var itemChangesetsForSections = [QuickDiffIndexPathChangeset]()
    for i in 0..<oldStructure.sections.count {
      if let newSectionIndex = sectionChangeset.newIndices[i] {

        let fromSection = i
        let toSection = newSectionIndex

        var fromArray = oldStructure.sections[fromSection].items
        if let sectionHeader = oldStructure.sections[fromSection].sectionHeader {
          fromArray.insert(sectionHeader, atIndex: 0)
        }

        var toArray = newStructure.sections[toSection].items
        if let sectionHeader = newStructure.sections[toSection].sectionHeader {
          toArray.insert(sectionHeader, atIndex: 0)
        }

        let itemIndexChangeset = QuickDiff.diffIndexPaths(
          oldArray: fromArray,
          newArray: toArray,
          fromSection: fromSection,
          toSection: toSection)

        itemChangesetsForSections.append(itemIndexChangeset)
      }
    }

    let itemChangeset: QuickDiffIndexPathChangeset = itemChangesetsForSections.reduce(QuickDiffIndexPathChangeset()) { masterChangeset, thisChangeset in

      let inserts: [NSIndexPath] = masterChangeset.inserts + thisChangeset.inserts
      let deletes: [NSIndexPath] = masterChangeset.deletes + thisChangeset.deletes
      let updates: [(NSIndexPath, NSIndexPath)] = masterChangeset.updates + thisChangeset.updates
      let moves: [(NSIndexPath, NSIndexPath)] = masterChangeset.moves + thisChangeset.moves

      return QuickDiffIndexPathChangeset(
        inserts: inserts,
        deletes: deletes,
        updates: updates,
        moves: moves)
    }
    
    return ListStructureChangeset(
      sectionChangeset: sectionChangeset,
      itemChangeset: itemChangeset)
  }
}
