// Created by Tyler Hedrick on 5/13/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - AnyEpoxyModel

/// A concrete `EpoxyableModel` wrapping a type-erased `EpoxyableModel`.
public struct AnyEpoxyModel: EpoxyModeled {

  // MARK: Lifecycle

  public init(_ model: EpoxyableModel) {
    // Disallow nesting `AnyEpoxyModel`s.
    self.model = model.eraseToAnyEpoxyModel().model
  }

  public init(internalEpoxyModel model: InternalEpoxyableModel) {
    self.model = model
  }

  // MARK: Public

  public var model: InternalEpoxyableModel

  /// Implemented as a passthrough to the backing model's storage to allow custom model properties
  /// to be accessed and modified through this type eraser.
  public var storage: EpoxyModelStorage {
    get { model.storage }
    set { model.storage = newValue }
  }

}

// MARK: EpoxyableModel

extension AnyEpoxyModel: EpoxyableModel {
  public func eraseToAnyEpoxyModel() -> AnyEpoxyModel { self }
}

// MARK: AnyEpoxyModel + DidSelect

extension AnyEpoxyModel {

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

extension AnyEpoxyModel: WillDisplayProviding {}

// MARK: DidEndDisplaying

extension AnyEpoxyModel: DidEndDisplayingProviding {}

// MARK: InternalEpoxyableModel

extension AnyEpoxyModel: InternalEpoxyableModel {
  public var reuseID: String {
    model.reuseID
  }

  public var isSelectable: Bool {
    model.isSelectable
  }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    model.configuredView(traitCollection: traitCollection)
  }

  public func configure(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    model.configure(cell: cell, with: metadata)
  }

  public func setBehavior(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    model.setBehavior(cell: cell, with: metadata)
  }

  public func configureStateChange(in cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    model.configureStateChange(in: cell, with: metadata)
  }

  public func handleDidSelect(_ cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
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

extension AnyEpoxyModel: Diffable {
  public var diffIdentifier: AnyHashable {
    model.diffIdentifier
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    // If comparing to another `AnyEpoxyModel`, compare the underlying models to one another since
    // concrete models attempt to cast the `Diffable` to their type.
    if let otherDiffableEpoxyItem = otherDiffableItem as? AnyEpoxyModel {
      return model.isDiffableItemEqual(to: otherDiffableEpoxyItem.model)
    }

    return model.isDiffableItemEqual(to: otherDiffableItem)
  }
}
