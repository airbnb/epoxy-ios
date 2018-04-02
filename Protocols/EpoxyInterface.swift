//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// A protocol for a view that can be powered by an array of `EpoxySection`s
public protocol EpoxyInterface: class {

  associatedtype Section: EpoxyableSection

  /// Whether to deselect items immediately after they are selected.
  var autoDeselectItems: Bool { get set }

  /// Sets the sections on the view
  func setSections(_ sections: [Section]?, animated: Bool)

  /// Selects the item and invokes the item's stateConfigurer
  /// Does not invoke selectionHandler
  func selectItem(at dataID: String, animated: Bool)

  /// Deselects the item and invokes the item's stateConfigurer
  func deselectItem(at dataID: String, animated: Bool)

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
