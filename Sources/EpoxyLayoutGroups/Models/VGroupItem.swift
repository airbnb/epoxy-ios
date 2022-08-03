// Created by Tyler Hedrick on 3/18/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - VGroupItem

/// An item you can use inside of any Group to represent a nested `VGroup`
public struct VGroupItem: EpoxyModeled {

  // MARK: Lifecycle

  /// Initializer to create a VGroupItem that represents a nested VGroup
  /// - Parameters:
  ///   - dataID: unique identifier for this item
  ///   - style: the style to configure the group with
  ///   - groupItems: the items that this group will render
  public init(
    dataID: AnyHashable,
    style: VGroup.Style = .init(),
    groupItems: Content)
  {
    self.style = style
    self.dataID = dataID
    self.groupItems = groupItems
  }

  /// Initializer to create a VGroupItem that represents a nested VGroup
  /// - Parameters:
  ///   - dataID: unique identifier for this item
  ///   - style: the style to configure the group with
  ///   - groupItemsBuilder: a builder used to build the items for this group
  public init(
    dataID: AnyHashable,
    style: VGroup.Style = .init(),
    @GroupModelBuilder _ groupItemsBuilder: () -> Content)
  {
    self.init(
      dataID: dataID,
      style: style,
      groupItems: groupItemsBuilder())
  }

  // MARK: Public

  public typealias Content = [GroupItemModeling]

  public var storage = EpoxyModelStorage()
  public var style: VGroup.Style
}

// MARK: AccessibilityAlignmentProviding

extension VGroupItem: AccessibilityAlignmentProviding { }

// MARK: DataIDProviding

extension VGroupItem: DataIDProviding { }

// MARK: HorizontalAlignmentProviding

extension VGroupItem: HorizontalAlignmentProviding { }

// MARK: PaddingProviding

extension VGroupItem: PaddingProviding { }

// MARK: VerticalAlignmentProviding

extension VGroupItem: VerticalAlignmentProviding { }

// MARK: GroupItemsProviding

extension VGroupItem: GroupItemsProviding { }

// MARK: GroupItemModeling

extension VGroupItem: GroupItemModeling {
  public func eraseToAnyGroupItem() -> AnyGroupItem {
    .init(internalGroupItemModel: self)
  }
}

// MARK: InternalGroupItemModeling

extension VGroupItem: InternalGroupItemModeling {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(
      dataID: dataID,
      style: style,
      accessibilityAlignment: accessibilityAlignment,
      horizontalAlignment: horizontalAlignment,
      padding: padding,
      verticalAlignment: verticalAlignment)
  }

  public func makeConstrainable() -> Constrainable {
    VGroup(
      style: style,
      items: groupItems)
      .accessibilityAlignment(accessibilityAlignment)
      .horizontalAlignment(horizontalAlignment)
      .padding(padding)
      .verticalAlignment(verticalAlignment)
  }

  public func update(_ constrainable: Constrainable, animated: Bool) {
    // Update can get called on containers as well, so we need to find
    // the wrapped constrainable to ensure we are passing in the proper value
    var toUpdate: Constrainable = constrainable
    if let container = constrainable as? ConstrainableContainer {
      toUpdate = container.wrapped
    }
    guard let group = toUpdate as? VGroup else {
      EpoxyLogger.shared
        .assertionFailure(
          "Attempt to update the wrong item type. This should never happen and is a failure of the system, please file a bug report")
      return
    }
    group.setItems(groupItems, animated: animated)
  }

  public func setBehaviors(on _: Constrainable) {
    // This shouldn't be necessary because we will always have `update()` called
    // on an HGroupItem and that will subsequently update our behaviors
  }

  public func isDiffableItemEqual(to _: Diffable) -> Bool {
    false
  }
}

// MARK: - DiffIdentifier

/// The identity of an item: a item view instance can be shared between two item model instances if
/// their `DiffIdentifier`s are equal. If they are not equal, the old item view will be considered
/// removed and a new item view will be created and inserted in its place.
private struct DiffIdentifier: Hashable {
  var dataID: AnyHashable
  var style: VGroup.Style
  var accessibilityAlignment: VGroup.ItemAlignment?
  var horizontalAlignment: VGroup.ItemAlignment?
  var padding: NSDirectionalEdgeInsets
  var verticalAlignment: HGroup.ItemAlignment?

  func hash(into hasher: inout Hasher) {
    hasher.combine(dataID)
    hasher.combine(style)
    hasher.combine(accessibilityAlignment)
    hasher.combine(horizontalAlignment)
    hasher.combine(verticalAlignment)
    hasher.combine(padding.top)
    hasher.combine(padding.leading)
    hasher.combine(padding.bottom)
    hasher.combine(padding.trailing)
  }
}
