// Created by amie_kweon on 4/10/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// Delegate for configuring swipe actions in a tableview row
public protocol TableViewEpoxyModelSwipeActionDelegate: AnyObject {
  @available(iOS 11.0, *)
  func tableView(
    _ tableView: UITableView,
    leadingSwipeActionsConfigurationForModel epoxyModel: EpoxyableModel,
    in section: EpoxyableSection) -> UISwipeActionsConfiguration?

  @available(iOS 11.0, *)
  func tableView(
    _ tableView: UITableView,
    trailingSwipeActionsConfigurationForModel epoxyModel: EpoxyableModel,
    in section: EpoxyableSection) -> UISwipeActionsConfiguration?

  func tableView(
    _ tableView: UITableView,
    editingStyleForModel epoxyModel: EpoxyableModel,
    in section: EpoxyableSection) -> UITableViewCell.EditingStyle
}
