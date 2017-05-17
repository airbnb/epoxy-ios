//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// A protocol for a view that can be powered by a `[ListSection]`
public protocol ListInterface: class {

  /// Sets the sections on the view
  func setSections(_ sections: [ListSection]?)

  /// Updates the item at the given data ID with the new item and configures the cell if it's visible
  func updateItem(at dataID: String, with item: ListItem, animated: Bool)

}

extension ListInterface {

  // Sets the items on the view
  public func setItems(_ items: [ListItem]) {
    let section = ListSection(items: items)
    setSections([section])
  }
}
