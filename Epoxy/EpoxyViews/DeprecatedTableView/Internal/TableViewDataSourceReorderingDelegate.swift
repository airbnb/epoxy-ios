// Created by amie_kweon on 10/30/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// Delegate for configuring a reordering behavior
protocol TableViewDataSourceReorderingDelegate: AnyObject {
  func dataSource(
    _ dataSource: UITableViewDataSource,
    canMoveRowWithDataID dataID: String,
    inSection sectionDataID: String) -> Bool

  func dataSource(
    _ dataSource: UITableViewDataSource,
    moveRowWithDataID dataID: String,
    inSectionWithDataID fromSectionDataID: String,
    toSectionWithDataID toSectionDataID: String,
    withDestinationDataID destinationDataID: String)
}
