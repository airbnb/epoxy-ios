//  Created by eric_horacek on 11/7/17.
//  Copyright © 2017 Airbnb. All rights reserved.

public protocol TableViewEpoxyModelDataSourcePrefetching: AnyObject {
  func tableView(
    _ tableView: TableView,
    prefetch epoxyItems: [EpoxyableModel])

  func tableView(
    _ tableView: TableView,
    cancelPrefetchingOf epoxyItems: [EpoxyableModel])
}
