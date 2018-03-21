//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation
import UIKit

/// The `EpoxyModel` contains the reference id for the model backing an item, the hash value of the item, as well as the reuse id for the item's type.
public protocol EpoxyableModel: class, Diffable {

  func configure(cell: EpoxyCell, forTraitCollection traitCollection: UITraitCollection, animated: Bool)
  func setBehavior(cell: EpoxyCell)

  // MARK: Optional

  var reuseID: String { get }
  var dataID: String? { get set }
  func configure(cell: EpoxyCell, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState)
  func didSelect(_ cell: EpoxyCell)

  var isSelectable: Bool { get set }
  var isMovable: Bool { get }
}

// MARK: Default implementations

extension EpoxyableModel {

  public var reuseID: String {
    return String(describing: type(of: self))
  }

  public var dataID: String? {
    return nil
  }

  public var selectionStyle: UITableViewCellSelectionStyle { return .default }

  public var isSelectable: Bool {
    get { return false }
    set { }
  }
  
  public var isMovable: Bool { return false }

  public func configure(cell: EpoxyCell, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState) { }

  public func didSelect(_ cell: EpoxyCell) { }
}

// MARK: Diffable

extension EpoxyableModel {

  public var diffIdentifier: String? {
    return dataID
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    return false
  }
}
