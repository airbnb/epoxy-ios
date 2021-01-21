// Created by eric_horacek on 12/14/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - AnySupplementaryItemModel

/// A concrete `SupplementaryItemModeling` wrapping a type-erased `SupplementaryItemModeling`.
public struct AnySupplementaryItemModel: EpoxyModeled {

  // MARK: Lifecycle

  public init(_ model: SupplementaryItemModeling) {
    // Disallow nesting `AnySupplementaryItemModel`s.
    self.model = model.eraseToAnySupplementaryItemModel().model
  }

  init(internalItemModel model: InternalSupplementaryItemModeling) {
    self.model = model
  }

  // MARK: Public

  /// Implemented as a passthrough to the backing model's storage to allow custom model properties
  /// to be accessed and modified through this type eraser.
  public var storage: EpoxyModelStorage {
    get { model.storage }
    set { model.storage = newValue }
  }

  // MARK: Internal

  var model: InternalSupplementaryItemModeling

}

// MARK: DataIDProviding

extension AnySupplementaryItemModel: DataIDProviding {}

// MARK: WillDisplayProviding

extension AnySupplementaryItemModel: WillDisplayProviding {}

// MARK: DidEndDisplayingProviding

extension AnySupplementaryItemModel: DidEndDisplayingProviding {}

// MARK: SupplementaryItemModeling

extension AnySupplementaryItemModel: SupplementaryItemModeling {
  public func eraseToAnySupplementaryItemModel() -> AnySupplementaryItemModel { self }
}

// MARK: InternalSupplementaryItemModeling

extension AnySupplementaryItemModel: InternalSupplementaryItemModeling {

  // MARK: Public

  public var viewDifferentiator: ViewDifferentiator {
    model.viewDifferentiator
  }

  public var dataID: AnyHashable {
    model.dataID
  }

  // MARK: Internal

  func configure(
    reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    model.configure(reusableView: reusableView, traitCollection: traitCollection, animated: animated)
  }

  func handleWillDisplay(
    _ view: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    model.handleWillDisplay(view, traitCollection: traitCollection, animated: animated)
    if let view = view.view {
      willDisplay?(.init(view: view, traitCollection: traitCollection, dataID: dataID, animated: animated))
    }
  }

  func handleDidEndDisplaying(
    _ view: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    model.handleDidEndDisplaying(view, traitCollection: traitCollection, animated: animated)
    if let view = view.view {
      didEndDisplaying?(.init(view: view, traitCollection: traitCollection, dataID: dataID, animated: animated))
    }
  }

  func setBehavior(
    reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    model.setBehavior(reusableView: reusableView, traitCollection: traitCollection, animated: animated)
  }
}

// MARK: Diffable

extension AnySupplementaryItemModel: Diffable {
  public var diffIdentifier: AnyHashable {
    model.diffIdentifier
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    // If comparing to another `AnySupplementaryItemModel`, compare the underlying models to one another since
    // concrete models attempt to cast the `Diffable` to their type.
    if let otherDiffableEpoxyItem = otherDiffableItem as? Self {
      return model.isDiffableItemEqual(to: otherDiffableEpoxyItem.model)
    }

    return model.isDiffableItemEqual(to: otherDiffableItem)
  }
}

// MARK: CallbackContextEpoxyModeled

extension AnySupplementaryItemModel: CallbackContextEpoxyModeled {

  /// The context passed to callbacks on an `AnySupplementaryItemModel`.
  public struct CallbackContext: ViewProviding, TraitCollectionProviding, AnimatedProviding {

    // MARK: Lifecycle

    public init(
      view: UIView,
      traitCollection: UITraitCollection,
      dataID: AnyHashable,
      animated: Bool)
    {
      self.view = view
      self.traitCollection = traitCollection
      self.dataID = dataID
      self.animated = animated
    }

    // MARK: Public

    public var view: UIView
    public var traitCollection: UITraitCollection
    public var dataID: AnyHashable
    public var animated: Bool
  }

}
