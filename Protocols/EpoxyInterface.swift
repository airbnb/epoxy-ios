//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// A protocol for a view that can be powered by an array of `EpoxySection`s
public protocol EpoxyInterface: class {

  associatedtype Section: EpoxyableSection

  /// Sets the sections on the view
  func setSections(_ sections: [Section]?, animated: Bool)

  /// Updates the item at the given data ID with the new item and configures the cell if it's visible
  func updateItem(at dataID: String, with item: EpoxyableModel, animated: Bool)

  /// Hides the bottom divider for the given dataIDs
  func hideBottomDivider(for dataIDs: [String])

}

extension EpoxyInterface where Section == EpoxySection {

  /// Sets the items on the view
  public func setItems(_ items: [EpoxyableModel], animated: Bool) {
    let section = EpoxySection(items: items)
    setSections([section], animated: animated)
  }
}
