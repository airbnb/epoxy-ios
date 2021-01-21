// Created by Tyler Hedrick on 5/13/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - AnyItemModel

/// A concrete `ItemModeling` wrapping a type-erased `ItemModeling`.
public struct AnyItemModel: EpoxyModeled {

  // MARK: Lifecycle

  public init(_ model: ItemModeling) {
    // Disallow nesting `AnyItemModel`s.
    self.model = model.eraseToAnyItemModel().model
  }

  public init(internalItemModel model: InternalItemModeling) {
    self.model = model
  }

  // MARK: Public

  public var model: InternalItemModeling

  /// Implemented as a passthrough to the backing model's storage to allow custom model properties
  /// to be accessed and modified through this type eraser.
  public var storage: EpoxyModelStorage {
    get { model.storage }
    set { model.storage = newValue }
  }

}

// MARK: WillDisplayProviding

extension AnyItemModel: WillDisplayProviding {}

// MARK: DidEndDisplayingProviding

extension AnyItemModel: DidEndDisplayingProviding {}

// MARK: DidSelectProviding

extension AnyItemModel: DidSelectProviding {}

// MARK: ItemModeling

extension AnyItemModel: ItemModeling {
  public func eraseToAnyItemModel() -> AnyItemModel { self }
}

// MARK: InternalItemModeling

extension AnyItemModel: InternalItemModeling {
  public var viewDifferentiator: ViewDifferentiator {
    model.viewDifferentiator
  }

  public var isSelectable: Bool {
    model.isSelectable
  }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    model.configuredView(traitCollection: traitCollection)
  }

  public func configure(cell: ItemWrapperView, with metadata: ItemCellMetadata) {
    model.configure(cell: cell, with: metadata)
  }

  public func setBehavior(cell: ItemWrapperView, with metadata: ItemCellMetadata) {
    model.setBehavior(cell: cell, with: metadata)
  }

  public func configureStateChange(in cell: ItemWrapperView, with metadata: ItemCellMetadata) {
    model.configureStateChange(in: cell, with: metadata)
  }

  public func handleDidSelect(_ cell: ItemWrapperView, with metadata: ItemCellMetadata) {
    model.handleDidSelect(cell, with: metadata)
    if let view = cell.view {
      didSelect?(.init(view: view, dataID: dataID, metadata: metadata))
    }
  }

  public func handleWillDisplay(_ cell: ItemWrapperView, with metadata: ItemCellMetadata) {
    model.handleWillDisplay(cell, with: metadata)
    if let view = cell.view {
      willDisplay?(.init(view: view, dataID: dataID, metadata: metadata))
    }
  }

  public func handleDidEndDisplaying(_ cell: ItemWrapperView, with metadata: ItemCellMetadata) {
    model.handleDidEndDisplaying(cell, with: metadata)
    if let view = cell.view {
      didEndDisplaying?(.init(view: view, dataID: dataID, metadata: metadata))
    }
  }
}

// MARK: Diffable

extension AnyItemModel: Diffable {
  public var diffIdentifier: AnyHashable {
    model.diffIdentifier
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    // If comparing to another `AnyItemModel`, compare the underlying models to one another since
    // concrete models attempt to cast the `Diffable` to their type.
    if let otherDiffableEpoxyItem = otherDiffableItem as? AnyItemModel {
      return model.isDiffableItemEqual(to: otherDiffableEpoxyItem.model)
    }

    return model.isDiffableItemEqual(to: otherDiffableItem)
  }
}

// MARK: CallbackContextEpoxyModeled

extension AnyItemModel: CallbackContextEpoxyModeled {

  /// The context passed to callbacks on an `AnyItemModel`.
  public struct CallbackContext: ViewProviding, TraitCollectionProviding, AnimatedProviding {

    // MARK: Lifecycle

    public init(
      view: UIView,
      traitCollection: UITraitCollection,
      state: ItemCellState,
      dataID: AnyHashable,
      animated: Bool)
    {
      self.view = view
      self.traitCollection = traitCollection
      self.state = state
      self.dataID = dataID
      self.animated = animated
    }

    public init(view: UIView, dataID: AnyHashable, metadata: ItemCellMetadata) {
      self.view = view
      traitCollection = metadata.traitCollection
      state = metadata.state
      self.dataID = dataID
      animated = metadata.animated
    }

    // MARK: Public

    public var dataID: AnyHashable
    public var view: UIView
    public var traitCollection: UITraitCollection
    public var state: ItemCellState
    public var animated: Bool
  }

}
