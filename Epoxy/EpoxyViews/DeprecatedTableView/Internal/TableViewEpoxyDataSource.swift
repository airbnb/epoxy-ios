//  Created by Laura Skelton on 4/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public class TableViewEpoxyDataSource: EpoxyDataSource<DeprecatedTableView>, UITableViewDataSource {

  // MARK: Public

  public func numberOfSections(in tableView: UITableView) -> Int {
    guard let data = internalData else { return 0 }

    return data.sections.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let data = internalData else { return 0 }

    return data.sections[section].items.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let item = epoxyModel(at: indexPath) else {
      epoxyLogger.epoxyAssertionFailure("Index path is out of bounds.")
      return UITableViewCell(style: .default, reuseIdentifier: "")
    }

    let cell = tableView.dequeueReusableCell(
      withIdentifier: item.epoxyModel.reuseID,
      for: indexPath)

    if let cell = cell as? TableViewCell {
      epoxyInterface?.configure(cell: cell, with: item)
    } else {
      epoxyLogger.epoxyAssertionFailure("Only TableViewCell and subclasses are allowed in a DeprecatedTableView.")
    }
    return cell
  }

  public func tableView(
    _ tableView: UITableView,
    canMoveRowAt indexPath: IndexPath) -> Bool
  {
    guard
      let reorderingDelegate = reorderingDelegate,
      let (dataID, sectionDataID) = dataIDs(at: indexPath) else
    { return false }

    return reorderingDelegate.dataSource(
      self,
      canMoveRowWithDataID: dataID,
      inSection: sectionDataID)
  }

  public func tableView(
    _ tableView: UITableView,
    moveRowAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath)
  {
    guard
      let (fromDataID, fromSectionDataID) = dataIDs(at: sourceIndexPath),
      let toSectionDataID = epoxySection(at: destinationIndexPath.section)?.dataID else
    { return }

    let beforeIndexPath = IndexPath(
      row: destinationIndexPath.row,
      section: destinationIndexPath.section)

    if let data = internalData,
      data.sections[beforeIndexPath.section].items.count >= beforeIndexPath.row + 1,
      let toDataID = epoxyModel(at: beforeIndexPath)?.dataID {
      reorderingDelegate?.dataSource(
        self,
        moveRowWithDataID: fromDataID,
        inSectionWithDataID: fromSectionDataID,
        toSectionWithDataID: toSectionDataID,
        withDestinationDataID: toDataID)
    }
  }

  // MARK: Internal

  weak var reorderingDelegate: TableViewDataSourceReorderingDelegate?

  func epoxyModel(at indexPath: IndexPath) -> EpoxyModelWrapper? {
    guard let data = internalData else {
      epoxyLogger.epoxyAssertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < indexPath.section + 1 {
      return nil
    }

    let section = data.sections[indexPath.section]

    if section.items.count < indexPath.row + 1 {
      return nil
    }

    return section.items[indexPath.row]
  }

  func epoxySection(at index: Int) -> InternalEpoxySection? {
    guard let data = internalData else {
      epoxyLogger.epoxyAssertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < index + 1 {
      epoxyLogger.epoxyAssertionFailure("Section is out of bounds.")
      return nil
    }

    return data.sections[index]
  }

  // MARK: Private

  /// Returns dataID and sectionDataID as a tuple at the given index path
  private func dataIDs(at indexPath: IndexPath) -> (String, String)? {
    guard
      let dataID = epoxyModel(at: indexPath)?.dataID,
      let sectionDataID = epoxySection(at: indexPath.section)?.dataID else
    { return nil }
    return (dataID, sectionDataID)
  }
}
