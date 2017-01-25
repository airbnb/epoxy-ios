//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

public typealias ViewMaker = () -> UIView

public protocol ListInterface {

  func setStructure(_ structure: ListStructure?)
}

extension ListInterface {

  public func setItems(_ items: [ListItem]) {
    let structure = ListStructure(items: items)
    setStructure(structure)
  }
}
