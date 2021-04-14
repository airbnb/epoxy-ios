// Created by Tyler Hedrick on 3/18/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import Foundation

// MARK: - AnyGroupItem

/// A concrete `GroupItemModeling` wrapping a type-erased `GroupItemModeling`.
public struct AnyGroupItem: Diffable {

  // MARK: Lifecycle

  init(_ model: GroupItemModeling) {
    // Disallow nesting `AnyGroupItem`s
    self.model = model.eraseToAnyGroupItem().model
  }

  init(internalGroupItemModel model: InternalGroupItemModeling) {
    self.model = model
  }

  // MARK: Public

  public var diffIdentifier: AnyHashable {
    model.diffIdentifier
  }

  /// Implemented as a passthrough to the backing model's storage to allow custom model properties
  /// to be accessed and modified through this type eraser.
  public var storage: EpoxyModelStorage {
    get { model.storage }
    set { model.storage = newValue }
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    // If comparing to another `AnyGroupItem`, compare the underlying models to one another since
    // concrete models attempt to cast the `Diffable` to their type.
    if let otherDiffableEpoxyItem = otherDiffableItem as? AnyGroupItem {
      return model.isDiffableItemEqual(to: otherDiffableEpoxyItem.model)
    }

    return model.isDiffableItemEqual(to: otherDiffableItem)
  }

  // MARK: Private

  private var model: InternalGroupItemModeling
}

// MARK: GroupItemModeling

extension AnyGroupItem: GroupItemModeling {
  public func eraseToAnyGroupItem() -> AnyGroupItem {
    self
  }
}

// MARK: InternalGroupItemModeling

extension AnyGroupItem: InternalGroupItemModeling {
  public var dataID: AnyHashable {
    model.dataID
  }

  public func makeConstrainable() -> Constrainable {
    model.makeConstrainable()
  }

  public func update(_ constrainable: Constrainable) {
    model.update(constrainable)
    setContent?(.init(constrainable: constrainable))
  }

  public func setBehaviors(on constrainable: Constrainable) {
    model.setBehaviors(on: constrainable)
    setBehaviors?(.init(constrainable: constrainable))
  }

}

// MARK: DataIDProviding

extension AnyGroupItem: DataIDProviding { }

// MARK: SetContentProviding

extension AnyGroupItem: SetContentProviding { }

// MARK: SetBehaviorsProviding

extension AnyGroupItem: SetBehaviorsProviding { }

// MARK: CallbackContextEpoxyModeled

extension AnyGroupItem: CallbackContextEpoxyModeled {
  public struct CallbackContext {
    public let constrainable: Constrainable

    public init(constrainable: Constrainable) {
      self.constrainable = constrainable
    }
  }
}
