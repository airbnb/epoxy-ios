// Created by eric_horacek on 1/5/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - AnyBarModel

/// A wrapper type that allows the `InternalBarModeling` and `InternalBarCoordinating` protocols to
/// be internal.
public struct AnyBarModel: EpoxyModeled {

  // MARK: Lifecycle

  init(_ model: InternalBarCoordinating) {
    self.model = model
  }

  // MARK: Internal

  /// Intentionally not public.
  var model: InternalBarCoordinating

  /// Implemented as a passthrough to the backing model's storage to allow custom model properties
  /// to be accessed and modified through this type eraser.
  public var storage: EpoxyModelStorage {
    get { model.storage }
    set { model.storage = newValue }
  }

}

// MARK: BarModeling

extension AnyBarModel: BarModeling {
  public func eraseToAnyBarModel() -> AnyBarModel { self }
}

// MARK: DataIDProviding

extension AnyBarModel: DataIDProviding {}

// MARK: StyleIDProviding

extension AnyBarModel: StyleIDProviding {}

// MARK: Diffable

extension AnyBarModel: Diffable {
  public var diffIdentifier: AnyHashable {
    model.diffIdentifier
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    // If comparing to another `AnyBarModel`, compare the underlying models to one another since
    // concrete models attempt to cast the `Diffable` to their type.
    if let otherDiffableItem = otherDiffableItem as? AnyBarModel {
      return model.isDiffableItemEqual(to: otherDiffableItem.model)
    }

    return model.isDiffableItemEqual(to: otherDiffableItem)
  }
}

// MARK: CallbackContextEpoxyModeled

extension AnyBarModel: CallbackContextEpoxyModeled {
	public typealias CallbackContext = Void
}

// MARK: WillDisplayProviding

extension AnyBarModel: WillDisplayProviding {}

// MARK: InternalBarModeling

extension AnyBarModel: InternalBarModeling {
  func makeConfiguredView(traitCollection: UITraitCollection) -> UIView {
    UIView()
  }
  
  func configureContent(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    // no-op
  }
  
  func configureBehavior(_ view: UIView, traitCollection: UITraitCollection) {
    // no-op
  }
  
  func willDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    willDisplay?(())
  }
  
  func didDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    // no-op
  }
  
  func didEndDisplaying(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    // no-op
  }
  
  func didSelect(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    // no-op
  }
  
  var isSelectable: Bool {
    false
  }
  
  
}
