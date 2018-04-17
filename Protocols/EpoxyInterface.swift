//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// A protocol for a view that can be powered by an array of `EpoxySection`s
public protocol EpoxyInterface: class {

  /// Whether to deselect items immediately after they are selected.
  var autoDeselectItems: Bool { get set }

  /// The selection style of the cells
  var selectionStyle: CellSelectionStyle { get set }

  /// Selects the item and invokes the item's stateConfigurer
  /// Does not invoke selectionHandler
  func selectItem(at dataID: String, animated: Bool)

  /// Deselects the item and invokes the item's stateConfigurer
  func deselectItem(at dataID: String, animated: Bool)

  /// Updates the item at the given data ID with the new item and configures the cell if it's visible
  func updateItem(at dataID: String, with item: EpoxyableModel, animated: Bool)

  /// Hides the bottom divider for the given dataIDs
  func hideBottomDivider(for dataIDs: [String])

  /// Scrolls to the item at the given dataID
  func scrollToItem(at dataID: String)

  /// Sets the item at the given dataID as the first responder
  func setItemAsFirstResponder(at dataID: String)

  /// Recalculates all cell heights in the epoxy interface
  /// NOTE: This has only been implemented for TableView, not for CollectionView.
  func recalculateCellHeights()
}

/// A protocol for a view that can be powered by an array of `EpoxySection`s
public protocol TypedEpoxyInterface: EpoxyInterface {
  associatedtype Section: EpoxyableSection

  /// Sets the sections on the view
  func setSections(_ sections: [Section]?, animated: Bool)
}

extension TypedEpoxyInterface where Section == EpoxySection {

  /// Sets the items on the view
  public func setItems(_ items: [EpoxyableModel], animated: Bool) {
    let section = EpoxySection(items: items)
    setSections([section], animated: animated)
  }
}
