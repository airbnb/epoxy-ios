//  Created by Laura Skelton on 5/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// A protocol used internally for a view that can be powered by an array of`EpoxySection`s
public protocol InternalEpoxyInterface: EpoxyInterface {

  /// The associated internal data type that powers this type of `EpoxyInterface`
  associatedtype DataType: InternalEpoxyDataType

  /// The type of cell view that this type of `EpoxyInterface` contains
  associatedtype Cell: UIView

  /// The currently visible index paths
  var visibleIndexPaths: [IndexPath] { get }

  /// Registers the given `cellReuseID`s for reusable cells
  func register(cellReuseID: String)

  /// Registers the given `supplementaryViewReuseID`s for reusable supplementary views of the given element kind
  func register(supplementaryViewReuseID: String, forKind elementKind: String)

  /// Reloads all data without diffing
  func reloadData()

  /// Reloads a particular item at the given index path and sets its behavior
  func reloadItem(at indexPath: IndexPath, animated: Bool)

  /// Configures the given cell with the given item and sets its behavior
  func configure(cell: Cell, with item: DataType.Item)

  /// Applies the given changeset to the view, allowing the view to animate changes
  func apply(_ newData: DataType?, animated: Bool, changesetMaker: @escaping (DataType?) -> EpoxyChangeset?)
  
}
