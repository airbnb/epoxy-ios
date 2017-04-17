//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// A block that makes a `UIView`
public typealias ViewMaker = () -> UIView

/// A protocol for a view that can be powered by a `ListStructure`
public protocol ListInterface: class {

  /// Registers the given `reuseID`s for reusable cells
  func register(reuseID: String)

  /// Unregisters the given `reuseID`s from the reusable cell pool
  func unregister(reuseID: String)

  /// Reloads all data without diffing
  func reloadData()

  /// Reloads a particular item at the given index path
  func reloadItem(at indexPath: IndexPath, animated: Bool)

  // Legacy behavior
  func setStructure(_ structure: ListStructure?)

}

extension ListInterface {

  // Legacy behavior
  public func setItems(_ items: [ListItem]) {
    let structure = ListStructure(items: items)
    setStructure(structure)
  }
}

/// A protocol for a view that can be powered by a `ListStructure` that animates changes
public protocol DiffableListInterface: ListInterface {

  /// The associated internal structure that powers this type of `ListInterface`
  associatedtype Structure: DiffableListInternalStructure

  /// The type of cell view that this type of `ListInterface` contains
  associatedtype Cell: UIView

  /// All visible cells, returned as strictly typed views
  var visibleTypedCells: [Cell] { get }

  /// Configures the given cell with the given item
  func configure(cell: Cell, with item: Structure.Item)

  /// Applies the given changeset to the view, allowing the view to animate changes
  func apply(_ changeset: Structure.Changeset)

}
