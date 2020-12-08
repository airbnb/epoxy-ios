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

// MARK: ItemModeling

extension AnyItemModel: ItemModeling {
  public func eraseToAnyItemModel() -> AnyItemModel { self }
}

// MARK: AnyItemModel + DidSelect

extension AnyItemModel {

  // MARK: Public

  /// A closure that's called when the view is selected, if the view is selectable.
  public typealias DidSelect = ((UIView, EpoxyViewMetadata) -> Void)

  /// A closure that's called when the view is selected, if the view is selectable.
  public var didSelect: DidSelect? {
    get { storage[didSelectProperty] }
    set { storage[didSelectProperty] = newValue }
  }

  /// Returns a copy of this model with the given did select closure called after the current did
  /// select closure of this model, if is one.
  public func didSelect(_ value: DidSelect?) -> Self {
    copy(updating: didSelectProperty, to: value)
  }

  // MARK: Private

  private var didSelectProperty: EpoxyModelProperty<DidSelect?> {
    .init(keyPath: \Self.didSelect, defaultValue: nil, updateStrategy: .chain())
  }
}

// MARK: WillDisplayProviding

extension AnyItemModel: WillDisplayProviding {}

// MARK: DidEndDisplaying

extension AnyItemModel: DidEndDisplayingProviding {}

// MARK: InternalItemModeling

extension AnyItemModel: InternalItemModeling {
  public var reuseID: String {
    model.reuseID
  }

  public var isSelectable: Bool {
    model.isSelectable
  }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    model.configuredView(traitCollection: traitCollection)
  }

  public func configure(cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    model.configure(cell: cell, with: metadata)
  }

  public func setBehavior(cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    model.setBehavior(cell: cell, with: metadata)
  }

  public func configureStateChange(in cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    model.configureStateChange(in: cell, with: metadata)
  }

  public func handleDidSelect(_ cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    model.handleDidSelect(cell, with: metadata)
    if let view = cell.view {
      didSelect?(view, metadata)
    }
  }

  public func handleWillDisplay() {
    model.handleWillDisplay()
  }

  public func handleDidEndDisplaying() {
    model.handleDidEndDisplaying()
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
