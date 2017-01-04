//  Created by Laura Skelton on 12/1/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

extension TableView {

  /// A `TableView` that gets its data from a `ListStructure` and calls `reloadData()` on updates.
  public static var tableView: TableView {
    return TableView(updateBehavior: .Reloads)
  }

  /// A `TableView` that gets its data from a `ListStructure`.
  /// On updates, it diffs between old and new `ListStructure`s and animates any insertions, deletions,
  /// updates, and moves.
  public static var diffingTableView: TableView {
    return TableView(updateBehavior: .Diffs)
  }

  /// A `TableView` that gets its data from a `ListStructure` and calls `reloadData()` on updates.
  /// It is configured with standard dividers.
  public static var standardTableView: TableView {
    let tableView = TableView(updateBehavior: .Reloads)
    tableView.setDividerViewMaker {
      return Divider.rowDivider
    }
    tableView.setSectionHeaderDividerViewMaker {
      return Divider.noDivider
    }
    return tableView
  }

  /// A `TableView` that gets its data from a `ListStructure`.
  /// On updates, it diffs between old and new `ListStructure`s and animates any insertions, deletions,
  /// updates, and moves. It is configured with standard dividers.
  public static var standardDiffingTableView: TableView {
    let tableView = TableView(updateBehavior: .Diffs)
    tableView.setDividerViewMaker {
      return Divider.rowDivider
    }
    tableView.setSectionHeaderDividerViewMaker {
      return Divider.noDivider
    }
    return tableView
  }
}
