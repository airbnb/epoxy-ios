//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

public protocol ListInterface {

  func setStructure(structure: ListStructure?)

  func registerReuseID<T where T: UIView>(
    reuseID: String, forViewMaker
    viewMaker: () -> T,
    viewConfigurer: (T, ListItemID, Bool) -> Void,
    selectionHandler: ListItemSelectionHandler?)
}
