// Created by Tyler Hedrick on 3/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

@dynamicMemberLookup
public struct GroupItem<ItemType: Constrainable>: EpoxyModeled {
  /// Create a GroupItem
  /// - Parameters:
  ///   - dataID: a unique identifier for this group item
  ///   - make: a closure that creates an instance of `ItemType`
  public init(
    dataID: AnyHashable,
    make: @escaping () -> ItemType)
  {
    self.make = make
    self.dataID = dataID
  }

  /// Create a GroupItem
  /// - Parameters:
  ///   - dataID: a unique identifier for this group item
  ///   - content: the content this group item needs to render
  ///   - make: a clsoure that creates an instance of `ItemType`
  ///   - setContent: a closure used to set the content on the `ItemType` instance
  public init<Content: Equatable>(
    dataID: AnyHashable,
    content: Content,
    make: @escaping () -> ItemType,
    setContent: @escaping (CallbackContext, Content) -> Void)
  {
    self.make = make
    self.dataID = dataID
    erasedContent = content
    self.setContent = { setContent($0, content) }
    isErasedContentEqual = { otherModel in
      guard let otherContent = otherModel.erasedContent as? Content else { return false }
      return otherContent == content
    }
  }

  /// Create a GroupItem
  /// - Parameters:
  ///   - dataID: a unique identifier for this group item
  ///   - params: the params that will be passed into the make closure
  ///   - content: the content this group items needs to render
  ///   - make: a closure that creates an instance of `ItemType`. This closure will
  ///           be provided the `Params` instance provided
  ///   - setContent: a closure used to set the content on the `ItemType` instance
  public init<Params: Hashable, Content: Equatable>(
    dataID: AnyHashable,
    params: Params,
    content: Content,
    make: @escaping (Params) -> ItemType,
    setContent: @escaping (CallbackContext, Content) -> Void)
  {
    self.make = { make(params) }
    self.dataID = dataID
    erasedContent = content
    self.setContent = { setContent($0, content) }
    isErasedContentEqual = { otherModel in
      guard let otherContent = otherModel.erasedContent as? Content else { return false }
      return otherContent == content
    }
  }

  // MARK: Public

  /// Set a value on this group item for the provided keypath. Note that this value will
  /// be set on any update to the group, so use this sparingly. Try to set values in the
  /// Content or Style of your Constrainable
  /// - Parameters:
  ///   - keypath: the keypath for the constrainable this group item is modeling
  ///   - value: the value to set
  /// - Returns: a copy of the group item with a behavior that updates the keypath to the provided value
  public func set<Value>(_ keypath: ReferenceWritableKeyPath<ItemType, Value>, value: Value) -> Self {
    setBehaviors { context in
      context.constrainable[keyPath: keypath] = value
    }
  }

  /// Set a value on this group item for the provided keypath. Note that this will attempt
  /// to set the value on any update to the group so use this sparingly. Try to set values in the
  /// Content or Style of your Constrainable. This Equatable value version of the set method will
  /// only update the value if it differs from the one currently set on the Constrainable
  /// - Parameters:
  ///   - keypath: the keypath for the constrainable this group item is modeling
  ///   - value: the value to set
  /// - Returns: a copy of the group item with a behavior that updates the keypath to the provided value
  public func set<Value: Equatable>(_ keypath: ReferenceWritableKeyPath<ItemType, Value>, value: Value) -> Self {
    setBehaviors { context in
      // no need to update this property as it is already set
      guard context.constrainable[keyPath: keypath] != value else {
        return
      }
      context.constrainable[keyPath: keypath] = value
    }
  }

  /// A dynamic member lookup version of the set method above.
  ///
  /// This allows you to do things like:
  /// ```
  /// Label.groupItem(
  ///   dataID: DataID.title,
  ///   content: "My title",
  ///   style: .title)
  ///   .numberOfLines(2)
  /// ```
  public subscript<Value>(dynamicMember keypath: ReferenceWritableKeyPath<ItemType, Value>) -> ((_ value: Value) -> Self) {
    return { value in
      set(keypath, value: value)
    }
  }

  /// A dynamic member lookup version of the equatable set method above.
  ///
  /// This allows you to do things like:
  /// ```
  /// Label.groupItem(
  ///   dataID: DataID.title,
  ///   content: "My title",
  ///   style: .title)
  ///   .numberOfLines(2)
  /// ```
  public subscript<Value: Equatable>(dynamicMember keypath: ReferenceWritableKeyPath<ItemType, Value>) -> ((_ value: Value) -> Self) {
    return { value in
      set(keypath, value: value)
    }
  }

  public var make: () -> ItemType

  public var storage = EpoxyModelStorage()
}

// MARK: GroupItem + UIView extensions

extension GroupItem where ItemType: UIView {
  /// Set the content compression resistance priority for the underlying UIView.
  /// Calling this method on a GroupItem for a non-UIView class will do nothing.
  /// - Parameters:
  ///   - priority: the content compression resitance priority
  ///   - axis: the axis this priority should be applied to
  /// - Returns: a copy of the model with the priority set
  public func contentCompressionResistancePriority(
    _ priority: UILayoutPriority,
    for axis: NSLayoutConstraint.Axis)
  -> Self
  {
    setBehaviors { context in
      context.constrainable.setContentCompressionResistancePriority(priority, for: axis)
    }
  }

  /// Set the content hugging priority for the underlying UIView
  /// Calling this method on a GroupItem for a non-UIView class will do nothing.
  /// - Parameters:
  ///   - priority: the content hugging priority
  ///   - axis: the axis this priority should be applied to
  /// - Returns: a copy of the model with the priority set
  public func contentHuggingPriority(
    _ priority: UILayoutPriority,
    for axis: NSLayoutConstraint.Axis)
  -> Self
  {
    setBehaviors { context in
      context.constrainable.setContentHuggingPriority(priority, for: axis)
    }
  }
}

// MARK: AccessibilityAlignmentProviding

extension GroupItem: AccessibilityAlignmentProviding { }

// MARK: DataIDProviding

extension GroupItem: DataIDProviding { }

// MARK: ErasedContentProviding

extension GroupItem: ErasedContentProviding { }

// MARK: HorizontalAlignmentProviding

extension GroupItem: HorizontalAlignmentProviding { }

// MARK: PaddingProviding

extension GroupItem: PaddingProviding { }

// MARK: SetBehaviorsProviding

extension GroupItem: SetBehaviorsProviding { }

// MARK: SetContentProviding

extension GroupItem: SetContentProviding { }

// MARK: VerticalAlignmentProviding

extension GroupItem: VerticalAlignmentProviding { }

// MARK: CallbackContextEpoxyModeled

extension GroupItem: CallbackContextEpoxyModeled {
  public struct CallbackContext {
    public let constrainable: ItemType

    public init(constrainable: ItemType) {
      self.constrainable = constrainable
    }
  }
}

// MARK: GroupItemModeling

extension GroupItem: GroupItemModeling {
  public func eraseToAnyGroupItem() -> AnyGroupItem {
    .init(internalGroupItemModel: self)
  }
}

// MARK: InternalGroupItemModeling

extension GroupItem: InternalGroupItemModeling {
  public func makeConstrainable() -> Constrainable {
    make()
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
    guard let item = toUpdate as? ItemType else {
      EpoxyLogger.shared.assertionFailure("Attempt to update constrainable of the wrong type. This should never happen and is a failure of the system, please file a bug report.")
      return
    }
    setContent?(.init(constrainable: item))
  }

  public func setBehaviors(on constrainable: Constrainable) {
    // setBehaviors can get called on containers as well, so we need to find
    // the wrapped constrainable to ensure we are passing in the proper value
    var toUpdate: Constrainable = constrainable
    if let container = constrainable as? ConstrainableContainer {
      toUpdate = container.wrapped
    }
    guard let item = toUpdate as? ItemType else {
      EpoxyLogger.shared.assertionFailure("Attempt to update constrainable of the wrong type. This should never happen and is a failure of the system, please file a bug report.")
      return
    }
    setBehaviors?(.init(constrainable: item))
  }
}

// MARK: Diffable

extension GroupItem {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(
      dataID: dataID,
      accessibilityAlignment: accessibilityAlignment,
      horizontalAlignment: horizontalAlignment,
      padding: padding,
      verticalAlignment: verticalAlignment)
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? GroupItem<ItemType> else {
      return false
    }
    if let contentEqual = isErasedContentEqual {
      return dataID == other.dataID && contentEqual(other)
    }
    return dataID == other.dataID
  }
}

// MARK: - DiffIdentifier

/// The identity of an item: a item view instance can be shared between two item model instances if
/// their `DiffIdentifier`s are equal. If they are not equal, the old item view will be considered
/// removed and a new item view will be created and inserted in its place.
private struct DiffIdentifier: Hashable {
  var dataID: AnyHashable
  var accessibilityAlignment: VGroup.ItemAlignment
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
