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
///
/// # Additional resources
/// - [Bar Installers Docs](***REMOVED***/projects/coreui/docs/navigation/bar_installers)
public struct BarModel<View: UIView, Content: Equatable>: ContentViewEpoxyModeled {

  // MARK: Lifecycle

  /// Constructs a bar model with a data ID, content, a closure to make the bar view, and a closure
  /// configure the bar view with new content whenever it changes.
  ///
  /// - Parameters:
  ///   - dataID: An optional ID that uniquely identifies this bar relative to other bars in the
  ///     same bar group.
  ///   - content: The content of the bar view that will be applied to the view in the `configure`
  ///     closure whenver it has changed.
  ///   - makeView: A closure that constructs the view of this bar. the `configure` closure is
  ///     called immediately after `makeView` with the returned view  to configure it with its
  ///     initial content.
  ///   - configureView: A closure that's called to configure the view with its content, both
  ///     immediately following its construction in `makeView` and subsequently whenever a new bar
  ///     model that replaced an old bar model with the same `dataID` has content that is not equal
  ///     to the content of the old bar model.
  public init(
    dataID: AnyHashable? = nil,
    content: Content,
    makeView: @escaping MakeView,
    configureView: @escaping ConfigureView)
  {
    if let dataID = dataID {
      self.dataID = dataID
    }
    self.content = content
    self.makeView = makeView
    self.configureView = configureView
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

// MARK: Providers

extension BarModel: AlternateStyleIDProviding {}
extension BarModel: ConfigureViewProviding {}
extension BarModel: ContentProviding {}
extension BarModel: DataIDProviding {}
extension BarModel: DidDisplayProviding {}
extension BarModel: MakeViewProviding {}
extension BarModel: SetBehaviorsProviding {}
extension BarModel: WillDisplayProviding {}

// MARK: BarModeling

extension BarModel: BarModeling {
  public func eraseToAnyBarModel() -> AnyBarModel { .init(self) }
}

// MARK: InternalBarModeling

extension BarModel: InternalBarModeling {
  func makeConfiguredView(traitCollection: UITraitCollection) -> UIView {
    let view = makeView()
    let context = CallbackContext(view: view, content: content, traitCollection: traitCollection, animated: false)
    configureView?(context)
    setBehaviors?(context)
    return view
  }

  func configureContent(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    configureView?(.init(view: castOrAssert(view), content: content, traitCollection: traitCollection, animated: animated))
  }

  func configureBehavior(_ view: UIView, traitCollection: UITraitCollection) {
    setBehaviors?(.init(view: castOrAssert(view), content: content, traitCollection: traitCollection, animated: false))
  }

  func willDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    willDisplay?(.init(view: castOrAssert(view), content: content, traitCollection: traitCollection, animated: animated))
  }

  func didDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool) {
    didDisplay?(.init(view: castOrAssert(view), content: content, traitCollection: traitCollection, animated: animated))
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
    DiffIdentifier(dataID: dataID, viewClass: .init(View.self), alternateStyleID: alternateStyleID)
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableItem = otherDiffableItem as? Self else { return false }
    return otherDiffableItem.content == content
  }
}

// MARK: CallbackContextEpoxyModeled

extension BarModel: CallbackContextEpoxyModeled {

  /// The context passed to callbacks on an `BarModel`.
  public struct CallbackContext: ViewProviding, ContentProviding, TraitCollectionProviding, AnimatedProviding {

    // MARK: Lifecycle

    public init(
      view: View,
      content: Content,
      traitCollection: UITraitCollection,
      animated: Bool)
    {
      self.view = view
      self.content = content
      self.traitCollection = traitCollection
      self.animated = animated
    }

    // MARK: Public

    public var view: View
    public var content: Content
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
  // The `View.Type` wrapped in `ObjectIdentifier` since `AnyClass` is not `Hashable`.
  var viewClass: ObjectIdentifier
  var alternateStyleID: AnyHashable?
}
