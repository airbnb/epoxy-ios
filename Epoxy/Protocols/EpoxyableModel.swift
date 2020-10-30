//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation
import UIKit

// MARK: - EpoxyUserInfoKey

/// Used for keys in Epoxy's userInfo dictionaries. The recommended way to use this
/// is define an extension on `EpoxyUserInfoKey` with defined `static var` values
/// that you use in your `userInfo` dictionary on `EpoxyableModel`s
public struct EpoxyUserInfoKey: RawRepresentable, Equatable, Hashable, Comparable {
  public typealias RawValue = String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public var rawValue: String

  public static func < (lhs: EpoxyUserInfoKey, rhs: EpoxyUserInfoKey) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

// MARK: - EpoxyableModel

/// The `EpoxyModel` contains the reference id for the model backing an item,
/// the hash value of the item, as well as the reuse id for the item's type.
public protocol EpoxyableModel: AnyObject, Diffable {

  /// configures the cell for presentation
  func configure(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  /// set behaviors needs by the cell. Is called before presentation and when cells are reordered
  func setBehavior(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  // MARK: Optional

  /// Default implementation generates a reuseID from the EpoxyableModel's class
  var reuseID: String { get }

  /// The ID that uniquely identifies this model across instances.
  var dataID: AnyHashable { get }

  /// Default implementation does nothing
  func configureStateChange(in cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  /// Default implementation does nothing
  func didSelect(_ cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  /// Default implementation does nothing
  func willDisplay()

  /// Default implementation does nothing
  func didEndDisplaying()

  /// Default value is `false`
  var isSelectable: Bool { get set }

  /// Default value is `nil`
  var selectionStyle: CellSelectionStyle? { get set }

  /// Default value is `false`
  var isMovable: Bool { get }

  /// This is used to store additional user-specific data similar to NSNotification's userInfo dictionary.
  /// The default value is the empty dictionary
  var userInfo: [EpoxyUserInfoKey: Any] { get }

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

  public var selectionStyle: CellSelectionStyle? {
    get { return nil }
    set { }
  }

  public var isSelectable: Bool {
    get { return false }
    set { }
  }

  public var isMovable: Bool { return false }

  public var userInfo: [EpoxyUserInfoKey: Any] { return [:] }

  public func configureStateChange(in cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) { }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    assertionFailure("Configured view not implemented for this Epoxyable model")
    return UIView()
  }

  public func didSelect(_ cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) { }

  public func willDisplay() { }

  public func didEndDisplaying() { }
}

// MARK: Diffable

extension EpoxyableModel {

  public var diffIdentifier: AnyHashable? {
    DiffIdentifier(reuseID: reuseID, dataID: dataID)
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    return false
  }
}

// MARK: - DiffIdentifier

private struct DiffIdentifier: Hashable {
  var reuseID: String
  var dataID: AnyHashable
}
