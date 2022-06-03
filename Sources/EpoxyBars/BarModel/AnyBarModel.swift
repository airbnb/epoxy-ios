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
  public struct CallbackContext: ViewProviding, TraitCollectionProviding, AnimatedProviding {
    public init(
      view: UIView,
      traitCollection: UITraitCollection,
      animated: Bool)
    {
      self.view = view
      self.traitCollection = traitCollection
      self.animated = animated
    }

    // MARK: Public

    public let view: UIView
    public let traitCollection: UITraitCollection
    public let animated: Bool
  }
}

// MARK: WillDisplayProviding

extension AnyBarModel: WillDisplayProviding {}

// MARK: InternalBarModeling

extension AnyBarModel: InternalBarModeling {

  var isSelectable: Bool {
    EpoxyLogger.shared.assertionFailure("isSelectable is unimplemented on AnyBarModel and should never be called")
    return false
  }

  func makeConfiguredView(traitCollection _: UITraitCollection) -> UIView {
    EpoxyLogger.shared.assertionFailure("makeConfiguredView is unimplemented on AnyBarModel and should never be called")
    return UIView()
  }

  func configureContent(_: UIView, traitCollection _: UITraitCollection, animated _: Bool) {
    EpoxyLogger.shared.assertionFailure("configureContent is unimplemented on AnyBarModel and should never be called")
  }

  func configureBehavior(_: UIView, traitCollection _: UITraitCollection) {
    EpoxyLogger.shared.assertionFailure("configureBehavior is unimplemented on AnyBarModel and should never be called")
  }

  func willDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    willDisplay?(.init(view: view, traitCollection: traitCollection, animated: animated))
  }

  func didDisplay(_: UIView, traitCollection _: UITraitCollection, animated _: Bool) {
    EpoxyLogger.shared.assertionFailure("didDisplay is unimplemented on AnyBarModel and should never be called")
  }

  func didEndDisplaying(_: UIView, traitCollection _: UITraitCollection, animated _: Bool) {
    EpoxyLogger.shared.assertionFailure("didEndDisplaying is unimplemented on AnyBarModel and should never be called")
  }

  func didSelect(_: UIView, traitCollection _: UITraitCollection, animated _: Bool) {
    EpoxyLogger.shared.assertionFailure("didSelect is unimplemented on AnyBarModel and should never be called")
  }
}
