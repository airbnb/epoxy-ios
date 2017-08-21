//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// The `EpoxyModel` contains the reference id for the model backing an item, the hash value of the item, as well as the reuse id for the item's type.
public protocol EpoxyableModel: Diffable {

  var reuseID: String { get }
  var dataID: String? { get }
  func configure(cell: EpoxyCell, animated: Bool)
  func configure(cell: EpoxyCell, forState state: EpoxyCellState)
  func setBehavior(cell: EpoxyCell)
  func didSelect(_ cell: EpoxyCell)

  var isSelectable: Bool { get }
}

extension EpoxyableModel {

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

  public var selectionStyle: UITableViewCellSelectionStyle { return .default }

  public var isSelectable: Bool { return false }

  public func didSelect(_ cell: EpoxyCell) { }

  public func configure(cell: EpoxyCell, forState state: EpoxyCellState) { }

}
