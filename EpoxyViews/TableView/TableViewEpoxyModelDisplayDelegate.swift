//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

public protocol TableViewEpoxyModelDisplayDelegate: class {
  func tableView(
    _ tableView: TableView,
    willDisplay epoxyModel: EpoxyableModel,
    in section: EpoxyableSection)

  func tableView(
    _ tableView: TableView,
    didEndDisplaying epoxyModel: EpoxyableModel,
    in section: EpoxyableSection)
}
