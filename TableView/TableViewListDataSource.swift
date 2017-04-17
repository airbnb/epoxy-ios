//  Created by Laura Skelton on 4/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public class TableViewListDataSource: ListDataSource<TableView>, UITableViewDataSource {

  // MARK: Public

  public func numberOfSections(in tableView: UITableView) -> Int {
    guard let structure = internalStructure else { return 0 }

    return structure.sections.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let structure = internalStructure else { return 0 }

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

    if let cell = cell as? TableViewCell {
      listInterface?.configure(cell: cell, with: item)
    } else {
      assert(false, "Only TableViewCell and subclasses are allowed in a TableView.")
    }
    return cell
  }

  // MARK: Internal

  func listItem(at indexPath: IndexPath) -> ListInternalTableViewItemStructure? {
    guard let structure = internalStructure else {
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
}
