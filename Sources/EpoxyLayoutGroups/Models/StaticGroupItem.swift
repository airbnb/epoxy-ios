// Created by Tyler Hedrick on 4/6/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - StaticGroupItem

/// A group item that vends a static `Constrainable`.
///
/// You can use this if you want to include a view in your group that has already been initialized.
/// ```
/// let titleLabel = UILabel()
/// titleLabel.text = "Title"
///
/// let subtitleLabel = UILabel()
/// subtitleLabel.text = "Subtitle"
///
/// let group = VGroup {
///   StaticGroupItem(titleLabel)
///   StaticGroupItem(subtitleLabel)
/// }
/// ```
public struct StaticGroupItem {

  // MARK: Lifecycle

  public init(_ constrainable: Constrainable) {
    self.constrainable = constrainable
    if let accessibilityAlignmentProviding = constrainable as? AccessibilityAlignmentProviding {
      accessibilityAlignment = accessibilityAlignmentProviding.accessibilityAlignment
    }
    if let horizontalAlignmentProviding = constrainable as? HorizontalAlignmentProviding {
      horizontalAlignment = horizontalAlignmentProviding.horizontalAlignment
    }
    if let paddingProviding = constrainable as? PaddingProviding {
      padding = paddingProviding.padding
    }
    if let verticalAlignmentProviding = constrainable as? VerticalAlignmentProviding {
      verticalAlignment = verticalAlignmentProviding.verticalAlignment
    }
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()

  // MARK: Private

  private let constrainable: Constrainable
}

// MARK: InternalGroupItemModeling

extension StaticGroupItem: InternalGroupItemModeling {

  // MARK: Public

  public var dataID: AnyHashable {
    constrainable.dataID
  }

  public var diffIdentifier: AnyHashable {
    DiffIdentifier(
      dataID: dataID,
      accessibilityAlignment: accessibilityAlignment,
      horizontalAlignment: horizontalAlignment,
      padding: padding,
      verticalAlignment: verticalAlignment)
  }

  public func eraseToAnyGroupItem() -> AnyGroupItem {
    .init(internalGroupItemModel: self)
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? StaticGroupItem else {
      return false
    }
    return other.constrainable.isEqual(to: constrainable)
  }

  // MARK: Internal

  func makeConstrainable() -> Constrainable {
    constrainable
      .accessibilityAlignment(accessibilityAlignment)
      .horizontalAlignment(horizontalAlignment)
      .padding(padding)
      .verticalAlignment(verticalAlignment)
  }

  func update(_: Constrainable, animated _: Bool) {
    // no-op
  }

  func setBehaviors(on _: Constrainable) {
    // no-op
  }

}

// MARK: AccessibilityAlignmentProviding

extension StaticGroupItem: AccessibilityAlignmentProviding { }

// MARK: DataIDProviding

extension StaticGroupItem: DataIDProviding { }

// MARK: HorizontalAlignmentProviding

extension StaticGroupItem: HorizontalAlignmentProviding { }

// MARK: PaddingProviding

extension StaticGroupItem: PaddingProviding { }

// MARK: VerticalAlignmentProviding

extension StaticGroupItem: VerticalAlignmentProviding { }

// MARK: - DiffIdentifier

/// The identity of an item: a item view instance can be shared between two item model instances if
/// their `DiffIdentifier`s are equal. If they are not equal, the old item view will be considered
/// removed and a new item view will be created and inserted in its place.
private struct DiffIdentifier: Hashable {
  var dataID: AnyHashable
  var accessibilityAlignment: VGroup.ItemAlignment?
  var horizontalAlignment: VGroup.ItemAlignment?
  var padding: NSDirectionalEdgeInsets
  var verticalAlignment: HGroup.ItemAlignment?

  func hash(into hasher: inout Hasher) {
    hasher.combine(dataID)
    hasher.combine(accessibilityAlignment)
    hasher.combine(horizontalAlignment)
    hasher.combine(verticalAlignment)
    hasher.combine(padding.top)
    hasher.combine(padding.leading)
    hasher.combine(padding.bottom)
    hasher.combine(padding.trailing)
  }
}
