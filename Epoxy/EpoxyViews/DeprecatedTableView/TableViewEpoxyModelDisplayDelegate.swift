//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

public protocol TableViewEpoxyModelDisplayDelegate: AnyObject {
  func tableView(
    _ tableView: DeprecatedTableView,
    willDisplay epoxyModel: EpoxyableModel,
    in section: EpoxyableSection)

  func tableView(
    _ tableView: DeprecatedTableView,
    didEndDisplaying epoxyModel: EpoxyableModel,
    in section: EpoxyableSection)
}
