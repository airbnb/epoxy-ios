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
public struct BarModel<View: UIView, Content: Equatable> {

  // MARK: Lifecycle

  /// Constructs a bar model with a data ID, content, a closure to make the bar view, and a closure
  /// configure the bar view with new content whenever it changes.
  ///
  /// - Parameters:
  ///   - dataID: An optional ID that uniquely identifies this bar relative to other bars in the
  ///     same bar group. Defaults to a representation of this view's type under the assumption that
  ///     it is unlikely to have the same bar multiple times in a single bar stack.
  ///   - content: The content of the bar view that will be applied to the view in the `configure`
  ///     closure whenver it has changed.
  ///   - makeView: A closure that constructs the view of this bar. the `configure` closure is
  ///     called immediately after `makeView` with the returned view  to configure it with its
  ///     initial content.
  ///   - configureContent: A closure that's called to configure the view with its content, both
  ///     immediately following its construction in `makeView` and subsequently whenever a new bar
  ///     model that replaced an old bar model with the same `dataID` has content that is not equal
  ///     to the content of the old bar model.
  public init(
    dataID: AnyHashable? = nil,
    content: Content,
    makeView: @escaping MakeView,
    configureContent: @escaping ConfigureContent)
  {
    // Default to the view type since it's unlikely that duplicate bars will be displayed.
    self.dataID = dataID ?? AnyHashable(ObjectIdentifier(View.self))
    self.content = content
    _makeView = makeView
    _configureContent = configureContent
  }

  // MARK: Public

  public typealias MakeView = () -> View
  public typealias ConfigureContent = (_ view: View, _ data: Content, _ animated: Bool) -> Void
  public typealias ConfigureBehaviors = (_ view: View) -> Void
  public typealias WillDisplay = (_ view: View) -> Void
  public typealias DidDisplay = (_ view: View) -> Void

  /// An optional ID for an alternative style type to use for reuse of this view. Use this to
  /// differentiate between different styling configurations.
  public func alternateStyleID(_ alternateStyleID: AnyHashable?) -> Self {
    var copy = self
    copy._alternateStyleID = alternateStyleID
    return copy
  }

  /// An optional closure that sets the view's behavior (such as interaction blocks or delegates).
  /// Called whenever a view is configured with a bar model.
  public func configureBehaviors(_ configureBehaviors: ConfigureBehaviors?) -> Self {
    guard let configureBehaviors = configureBehaviors else { return self }
    var copy = self
    copy._configureBehaviors = { [previous = copy._configureBehaviors] view in
      previous?(view)
      configureBehaviors(view)
    }
    return copy
  }

  /// An optional closure that's called whenever the view is about to display.
  public func willDisplay(_ willDisplay: WillDisplay?) -> Self {
    guard let willDisplay = willDisplay else { return self }
    var copy = self
    copy._willDisplay = { [previous = copy._willDisplay] content in
      previous?(content)
      willDisplay(content)
    }
    return copy
  }

  /// An optional closure that's called after the view has been displayed.
  public func didDisplay(_ didDisplay: DidDisplay?) -> Self {
    guard let didDisplay = didDisplay else { return self }
    var copy = self
    copy._didDisplay = { [previous = copy._didDisplay] content in
      previous?(content)
      didDisplay(content)
    }
    return copy
  }

  /// Updates the content to the given value.
  public func content(_ content: (inout Content) -> Void) -> Self {
    var copy = self
    content(&copy.content)
    return copy
  }

  /// Replaces the default closure to construct the view with the given closure.
  public func makeView(_ makeView: @escaping () -> View) -> Self {
    var copy = self
    copy._makeView = makeView
    return copy
  }

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

  private let dataID: AnyHashable
  private var content: Content
  private var _makeView: MakeView
  private var _configureContent: ConfigureContent
  private var _alternateStyleID: AnyHashable?
  private var _configureBehaviors: ConfigureBehaviors?
  private var _willDisplay: WillDisplay?
  private var _didDisplay: DidDisplay?
  private var coordinatorType: AnyClass = DefaultBarCoordinator<Self>.self
  private var _makeCoordinator: (_ update: @escaping (_ animated: Bool) -> Void) -> Coordinator = {
    AnyBarCoordinator(DefaultBarCoordinator(update: $0))
  }

  private func configure(_ view: View, animated: Bool) {
    _configureContent(view, content, animated)
  }

  private func castOrAssert(_ view: UIView) -> View? {
    guard let typedView = view as? View else {
      EpoxyLogger.shared.assertionFailure("\(view) is not of the expected type \(View.self)")
      return nil
    }
    return typedView
  }

}

// MARK: BarModeling

extension BarModel: BarModeling {
  public var barModel: AnyBarModel { .init(self) }
}

// MARK: InternalBarModeling

extension BarModel: InternalBarModeling {
  func makeConfiguredView() -> UIView {
    let view = _makeView()
    configure(view, animated: false)
    _configureBehaviors?(view)
    return view
  }

  func configureContent(_ view: UIView, animated: Bool) {
    guard let typedView = castOrAssert(view) else { return }
    configure(typedView, animated: animated)
  }

  func configureBehavior(_ view: UIView) {
    guard let typedView = castOrAssert(view) else { return }
    _configureBehaviors?(typedView)
  }

  func isContentEqual(to model: InternalBarModeling) -> Bool {
    guard let model = model as? Self else { return false }
    return model.content == content
  }

  func canReuseView(from model: InternalBarModeling) -> Bool {
    guard let model = model as? Self else { return false }
    return model._alternateStyleID == _alternateStyleID
  }

  func willDisplay(_ view: UIView) {
    guard let typedView = castOrAssert(view) else { return }
    _willDisplay?(typedView)
  }

  func didDisplay(_ view: UIView) {
    guard let typedView = castOrAssert(view) else { return }
    _didDisplay?(typedView)
  }
}

// MARK: InternalBarCoordinating

extension BarModel: InternalBarCoordinating {
  func barModel(for coordinator: AnyBarCoordinating) -> BarModeling {
    guard let typedCoordinator = coordinator as? Coordinator else {
      EpoxyLogger.shared.assertionFailure("\(coordinator) is not of the expected type \(Coordinator.self)")
      return self
    }
    return typedCoordinator.barModel(for: self)
  }

  func makeCoordinator(update: @escaping (Bool) -> Void) -> AnyBarCoordinating {
    _makeCoordinator(update)
  }

  func canReuseCoordinator(_ coordinator: AnyBarCoordinating) -> Bool {
    guard let typedCoordinator = coordinator as? Coordinator else { return false }
    return typedCoordinator.type == coordinatorType
  }
}

// MARK: Diffable

extension BarModel: Diffable {
  public var diffIdentifier: AnyHashable {
    dataID
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableItem = otherDiffableItem as? Self else { return false }
    return isContentEqual(to: otherDiffableItem)
  }
}
