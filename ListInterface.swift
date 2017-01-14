//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

public protocol ListInterface {

  func setStructure(_ structure: ListStructure?)

  func registerReuseID<T>(
    _ reuseID: String,
    forViewMaker viewMaker: @escaping () -> T,
    viewConfigurer: @escaping (T, ListItemID, Bool) -> Void,
    selectionHandler: ListItemSelectionHandler?) where T: UIView
}
