//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation
import UIKit

/// The `EpoxyModel` contains the reference id for the model backing an item, the hash value of the item, as well as the reuse id for the item's type.
public protocol EpoxyableModel: AnyObject, Diffable {

  func configure(cell: EpoxyWrapperView, forTraitCollection traitCollection: UITraitCollection, animated: Bool)
  func setBehavior(cell: EpoxyWrapperView)

  // MARK: Optional

  var reuseID: String { get }
  var dataID: String { get }
  func configure(cell: EpoxyWrapperView, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState)
  func didSelect(_ cell: EpoxyWrapperView)

  var isSelectable: Bool { get set }
  var selectionStyle: CellSelectionStyle? { get set }
  var isMovable: Bool { get }

  /// Creates view for this epoxy model. This should only be used to create a view outside of a
  /// collection or table view.
  ///
  /// - Parameter traitCollection: The trait collection to create the view for
  /// - Returns: The configured view for this epoxy model.
  func configuredView(traitCollection: UITraitCollection) -> UIView
}

// MARK: Default implementations

extension EpoxyableModel {

  public var reuseID: String {
    return String(describing: type(of: self))
  }

  public var dataID: String {
    return UUID().uuidString
  }

  public var selectionStyle: CellSelectionStyle? {
    get { return nil }
    set { }
  }

  public var isSelectable: Bool {
    get { return false }
    set { }
  }

  public var isMovable: Bool { return false }

  public func configure(cell: EpoxyWrapperView, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState) { }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    assertionFailure("Configured view not implemented for this Epoxyable model")
    return UIView()
  }

  public func didSelect(_ cell: EpoxyWrapperView) { }
}

// MARK: Diffable

extension EpoxyableModel {

  public var diffIdentifier: String? {
    return reuseID + dataID
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    return false
  }
}
