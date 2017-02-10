//
//  TableViewListItemDisplayDelegate.swift
//  AirbnbScratchComponents
//
//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//
//  REVIEWERS: laura-skelton

public protocol TableViewListItemDisplayDelegate: class {
  func tableView(
    _ tableView: TableView,
    willDisplay listItem: ListItem)
}
