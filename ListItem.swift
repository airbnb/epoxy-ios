//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// The `ListItem` contains the reference id for the model backing an item, the hash value of the item, as well as the reuse id for the item's type.
public protocol ListItem: Diffable {

  var reuseID: String { get }
  var dataID: String? { get }
  func configure(cell: ListCell, animated: Bool)
}

extension ListItem {

  public var diffIdentifier: String? {
    return dataID
  }

  public var reuseID: String {
    return String(describing: type(of: self))
  }

  public var dataID: String? {
    return nil
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    return false
  }
}
