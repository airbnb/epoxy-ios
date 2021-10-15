// Created by eric_horacek on 8/21/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - BarModel

/// A model that provides the content of a bar (e.g. a toolbar or a nav bar).
///
/// Conceptually similar to Epoxy models.
///
/// - SeeAlso: `BottomBarInstaller`
/// - SeeAlso: `TopBarInstaller`
public struct BarModel<View: UIView>: ViewEpoxyModeled {

  // MARK: Lifecycle

  /// Constructs a bar model with a data ID.
  ///
  /// - Parameters:
  ///   - dataID: An optional ID that uniquely identifies this bar relative to other bars in the
  ///     same bar stack.
  public init(dataID: AnyHashable? = nil) {
    if let dataID = dataID {
      self.dataID = dataID
    }
  }

  /// Constructs a bar model with a data ID, content, a closure to make the bar view, and a closure
  /// configure the bar view with new content whenever it changes.
  ///
  /// - Parameters:
  ///   - dataID: An optional ID that uniquely identifies this bar relative to other bars in the
  ///     same bar stack.
  ///   - content: The content of the bar view that will be applied to the view in the `setContent`
  ///     closure whenver it has changed.
  ///   - setContent: A closure that's called to configure the view with its content, both
  ///     immediately following its construction in `makeView` and subsequently whenever a new bar
  ///     model that replaced an old bar model with the same `dataID` has content that is not equal
  ///     to the content of the old bar model.
  public init<Content: Equatable>(
    dataID: AnyHashable? = nil,
    content: Content,
    setContent: @escaping (CallbackContext, Content) -> Void)
  {
    if let dataID = dataID {
      self.dataID = dataID
    }
    erasedContent = content
    self.setContent = { setContent($0, content) }
    isErasedContentEqual = { otherModel in
      guard let otherContent = otherModel.erasedContent as? Content else { return false }
      return otherContent == content
    }
  }

  /// Constructs a bar model with a data ID, initializer parameters, content, a closure to construct
  /// the view from the parameters, and a closure to configure the bar view with new content
  /// whenever it changes.
  ///
  /// - Parameters:
  ///   - dataID: An optional ID that uniquely identifies this bar relative to other bars in the
  ///     same bar stack.
  ///   - params: The parameters used to construct an instance of the view, passed into the
  ///     `makeView` function and used as a view reuse identifier.
  ///   - content: The content of the bar view that will be applied to the view in the
  ///     `setContent` closure whenver it has changed.
  ///   - makeView: A closure that's called with `params` to construct view instances as required.
  ///   - setContent: A closure that's called to configure the view with its content, both
  ///     immediately following its construction in `makeView` and subsequently whenever a new bar
  ///     model that replaced an old bar model with the same `dataID` has content that is not equal
  ///     to the content of the old bar model.
  public init<Params: Hashable, Content: Equatable>(
    dataID: AnyHashable? = nil,
    params: Params,
    content: Content,
    makeView: @escaping (Params) -> View,
    setContent: @escaping (CallbackContext, Content) -> Void)
  {
    if let dataID = dataID {
      self.dataID = dataID
    }
    styleID = params
    erasedContent = content
    self.makeView = { makeView(params) }
    self.setContent = { setContent($0, content) }
    isErasedContentEqual = { otherModel in
      guard let otherContent = otherModel.erasedContent as? Content else { return false }
      return otherContent == content
    }
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()

  /// Replaces the default closure to construct the coordinator with the given closure.
  public func makeCoordinator<Coordinator: BarCoordinating>(
    _ makeCoordinator: @escaping (_ update: @escaping (_ animated: Bool) -> Void) -> Coordinator)
    -> Self where
    Coordinator.Model == Self
  {
    var copy = self
    copy._makeCoordinator = { AnyBarCoordinator(makeCoordinator($0)) }
    copy.coordinatorType = Coordinator.self
    return copy
  }

  // MARK: Private

  private typealias Coordinator = AnyBarCoordinator<Self>

  private var coordinatorType: AnyClass?
  private var _makeCoordinator: ((_ update: @escaping (_ animated: Bool) -> Void) -> Coordinator)?

  private func castOrAssert(_ view: UIView) -> View {
    guard let typedView = view as? View else {
      EpoxyLogger.shared.assertionFailure(
        "\(view) is not of the expected type \(View.self). This is programmer error.")
      return makeView()
    }
    return typedView
  }

}

// MARK: SetContentProviding

extension BarModel: SetContentProviding {}

// MARK: ErasedContentProviding

extension BarModel: ErasedContentProviding {}

// MARK: DataIDProviding

extension BarModel: DataIDProviding {}

// MARK: DidDisplayProviding

extension BarModel: DidDisplayProviding {}

// MARK: MakeViewProviding

extension BarModel: MakeViewProviding {}

// MARK: SetBehaviorsProviding

extension BarModel: SetBehaviorsProviding {}

// MARK: StyleIDProviding

extension BarModel: StyleIDProviding {}

// MARK: WillDisplayProviding

extension BarModel: WillDisplayProviding {}

// MARK: DidSelectProviding

extension BarModel: DidSelectProviding {}

// MARK: BarModeling

extension BarModel: BarModeling {
  public func eraseToAnyBarModel() -> AnyBarModel { .init(self) }
}

// MARK: InternalBarModeling

extension BarModel: InternalBarModeling {
  var isSelectable: Bool {
    didSelect != nil
  }

  func makeConfiguredView(traitCollection: UITraitCollection) -> UIView {
    let view = makeView()
    let context = CallbackContext(view: view, traitCollection: traitCollection, animated: false)
    setContent?(context)
    setBehaviors?(context)
    return view
  }

  func configureContent(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    setContent?(.init(view: castOrAssert(view), traitCollection: traitCollection, animated: animated))
  }

  func configureBehavior(_ view: UIView, traitCollection: UITraitCollection) {
    setBehaviors?(.init(view: castOrAssert(view), traitCollection: traitCollection, animated: false))
  }

  func willDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    willDisplay?(.init(view: castOrAssert(view), traitCollection: traitCollection, animated: animated))
  }

  func didDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    didDisplay?(.init(view: castOrAssert(view), traitCollection: traitCollection, animated: animated))
  }

  func didSelect(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    didSelect?(.init(view: castOrAssert(view), traitCollection: traitCollection, animated: animated))
  }

}

// MARK: InternalBarCoordinating

extension BarModel: InternalBarCoordinating {
  public func barModel(for coordinator: AnyBarCoordinating) -> BarModeling {
    guard let typedCoordinator = coordinator as? Coordinator else {
      EpoxyLogger.shared.assertionFailure(
        "\(coordinator) is not of the expected type \(Coordinator.self). This is programmer error.")
      return self
    }
    return typedCoordinator.barModel(for: self)
  }

  public func makeCoordinator(update: @escaping (Bool) -> Void) -> AnyBarCoordinating {
    _makeCoordinator?(update) ?? AnyBarCoordinator(DefaultBarCoordinator())
  }

  public func canReuseCoordinator(_ coordinator: AnyBarCoordinating) -> Bool {
    guard let typedCoordinator = coordinator as? Coordinator else { return false }
    return typedCoordinator.type == coordinatorType
  }
}

// MARK: Diffable

extension BarModel: Diffable {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(dataID: dataID, viewClass: .init(View.self))
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? Self else { return false }
    return isErasedContentEqual?(other) ?? true
  }
}

// MARK: CallbackContextEpoxyModeled

extension BarModel: CallbackContextEpoxyModeled {

  /// The context passed to callbacks on an `BarModel`.
  public struct CallbackContext: ViewProviding, TraitCollectionProviding, AnimatedProviding {

    // MARK: Lifecycle

    public init(
      view: View,
      traitCollection: UITraitCollection,
      animated: Bool)
    {
      self.view = view
      self.traitCollection = traitCollection
      self.animated = animated
    }

    // MARK: Public

    public var view: View
    public var traitCollection: UITraitCollection
    public var animated: Bool
  }

}

// MARK: - DiffIdentifier

/// The identity of a bar: a bar view instance can be shared between two bar model instances if
/// their `DiffIdentifier`s are equal. If they are not equal, the old bar view will be considered
/// removed and a new bar view will be created and inserted in its place.
struct DiffIdentifier: Hashable {
  var dataID: AnyHashable
  // The `View.Type` wrapped in a `ClassReference` since `AnyClass` is not `Hashable`.
  var viewClass: ClassReference
}
