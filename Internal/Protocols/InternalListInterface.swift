//
//  InternalListInterface.swift
//  List
//
//  Created by Laura Skelton on 5/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

import Foundation

/// A protocol used internally for a view that can be powered by a `[ListSection]`
public protocol InternalListInterface: ListInterface {

  /// The associated internal data type that powers this type of `ListInterface`
  associatedtype DataType: DiffableInternalListDataType

  /// The type of cell view that this type of `ListInterface` contains
  associatedtype Cell: UIView

  /// The currently visible index paths
  var visibleIndexPaths: [IndexPath] { get }

  /// Registers the given `reuseID`s for reusable cells
  func register(reuseID: String)

  /// Unregisters the given `reuseID`s from the reusable cell pool
  func unregister(reuseID: String)

  /// Reloads all data without diffing
  func reloadData()

  /// Reloads a particular item at the given index path and sets its behavior
  func reloadItem(at indexPath: IndexPath, animated: Bool)

  /// Sets the behavior (such as blocks or delegate) for the item at the given index path without
  /// reloading the view
  func setBehavior(at indexPath: IndexPath)

  /// Configures the given cell with the given item and sets its behavior
  func configure(cell: Cell, with item: DataType.Item)

  /// Applies the given changeset to the view, allowing the view to animate changes
  func apply(_ changeset: DataType.Changeset)
  
}
