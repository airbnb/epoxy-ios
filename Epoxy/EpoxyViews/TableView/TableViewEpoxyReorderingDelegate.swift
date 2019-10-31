// Created by amie_kweon on 10/29/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// Delegate for configuring a reordering behavior
public protocol TableViewEpoxyReorderingDelegate: AnyObject {

  func tableView(
    _ tableView: UITableView,
    shouldIndentWhileEditingRowWithDataID dataID: String,
    inSection sectionDataID: String) -> Bool

  func tableView(
    _ tableView: UITableView,
    canMoveRowWithDataID dataID: String,
    inSection sectionDataID: String) -> Bool

  func tableView(
    _ tableView: UITableView,
    moveRowWithDataID dataID: String,
    inSectionWithDataID fromSectionDataID: String,
    toSectionWithDataID toSectionDataID: String,
    withDestinationDataID destinationDataID: String)
}
