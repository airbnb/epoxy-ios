// Created by Tyler Hedrick on 3/18/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - HGroupItem

/// An item you can use inside of any Group to represent a nested HGroup
public struct HGroupItem: EpoxyModeled {

  // MARK: Lifecycle

  /// Initializer to create a HGroupItem that represents a nested HGroup
  /// - Parameters:
  ///   - dataID: unique identifier for this item
  ///   - style: the style to configure the group with
  ///   - groupItems: the items that this group will render
  public init(
    dataID: AnyHashable,
    style: HGroup.Style,
    groupItems: [GroupItemModeling])
  {
    self.style = style
    self.dataID = dataID
    self.groupItems = groupItems
  }

  /// Initializer to create a HGroupItem that represents a nested HGroup
  /// - Parameters:
  ///   - dataID: unique identifier for this item
  ///   - style: the style to configure the group with
  ///   - groupItemsBuilder: a builder to construct items
  public init(
    dataID: AnyHashable,
    style: HGroup.Style,
    @GroupModelBuilder _ groupItemsBuilder: () -> [GroupItemModeling])
  {
    self.init(
      dataID: dataID,
      style: style,
      groupItems: groupItemsBuilder())
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()
  public var style: HGroup.Style
}

// MARK: AccessibilityAlignmentProviding

extension HGroupItem: AccessibilityAlignmentProviding { }

// MARK: DataIDProviding

extension HGroupItem: DataIDProviding { }

// MARK: HorizontalAlignmentProviding

extension HGroupItem: HorizontalAlignmentProviding { }

// MARK: PaddingProviding

extension HGroupItem: PaddingProviding { }

// MARK: ReflowsForAccessibilityTypeSizeProviding

extension HGroupItem: ReflowsForAccessibilityTypeSizeProviding { }

// MARK: VerticalAlignmentProviding

extension HGroupItem: VerticalAlignmentProviding { }

// MARK: GroupItemsProviding

extension HGroupItem: GroupItemsProviding { }

// MARK: GroupItemModeling

extension HGroupItem: GroupItemModeling {
  public func eraseToAnyGroupItem() -> AnyGroupItem {
    .init(internalGroupItemModel: self)
  }
}

// MARK: InternalGroupItemModeling

extension HGroupItem: InternalGroupItemModeling {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(
      dataID: dataID,
      style: style,
      reflowsForAccessibilityTypeSizes: reflowsForAccessibilityTypeSizes,
      accessibilityAlignment: accessibilityAlignment,
      horizontalAlignment: horizontalAlignment,
      padding: padding,
      verticalAlignment: verticalAlignment)
  }

  public func makeConstrainable() -> Constrainable {
    HGroup(
      alignment: style.alignment,
      accessibilityAlignment: style.accessibilityAlignment,
      spacing: style.spacing,
      items: groupItems)
      .reflowsForAccessibilityTypeSizes(reflowsForAccessibilityTypeSizes)
      .accessibilityAlignment(accessibilityAlignment)
      .horizontalAlignment(horizontalAlignment)
      .padding(padding)
      .verticalAlignment(verticalAlignment)
  }

  public func update(_ constrainable: Constrainable) {
    // Update can get called on containers as well, so we need to find
    // the wrapped constrainable to ensure we are passing in the proper value
    var toUpdate: Constrainable = constrainable
    if let container = constrainable as? ConstrainableContainer {
      toUpdate = container.wrapped
    }
    guard let hGroup = toUpdate as? HGroup else {
      EpoxyLogger.shared.assertionFailure("Attempt to update the wrong item type. This should never happen and is a failure of the system, please file a bug report")
      return
    }
    hGroup.setItems(groupItems)
  }

  public func setBehaviors(on constrainable: Constrainable) {
    // This shouldn't be necessary because we will always have `update()` called
    // on an HGroupItem and that will subsequently update our behaviors
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    false
  }
}

// MARK: - DiffIdentifier

/// The identity of an item: a item view instance can be shared between two item model instances if
/// their `DiffIdentifier`s are equal. If they are not equal, the old item view will be considered
/// removed and a new item view will be created and inserted in its place.
private struct DiffIdentifier: Hashable {
  var dataID: AnyHashable
  var style: HGroup.Style
  var reflowsForAccessibilityTypeSizes: Bool
  var accessibilityAlignment: VGroup.ItemAlignment
  var horizontalAlignment: VGroup.ItemAlignment?
  var padding: NSDirectionalEdgeInsets
  var verticalAlignment: HGroup.ItemAlignment?

  func hash(into hasher: inout Hasher) {
    hasher.combine(dataID)
    hasher.combine(style)
    hasher.combine(reflowsForAccessibilityTypeSizes)
    hasher.combine(accessibilityAlignment)
    hasher.combine(horizontalAlignment)
    hasher.combine(verticalAlignment)
    hasher.combine(padding.top)
    hasher.combine(padding.leading)
    hasher.combine(padding.bottom)
    hasher.combine(padding.trailing)
  }
}
