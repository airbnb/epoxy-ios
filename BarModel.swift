// Created by eric_horacek on 8/21/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import ConstellationCoreUI
import Epoxy
import UIKit

// MARK: - BarModel

/// A model that provides the content of a bar (e.g. a toolbar).
///
/// Conceptually similar to Epoxy models.
public struct BarModel<ViewType: UIView> where ViewType: ContentConfigurableView,
  ViewType: StyledView,
  ViewType.Content: Equatable
{

  // MARK: Lifecycle

  public init(dataID: AnyHashable? = nil, content: ViewType.Content, style: ViewType.Style) {
    // Default to the view type since it's unlikely that duplicate bars will be displayed.
    self.dataID = dataID ?? AnyHashable(ObjectIdentifier(ViewType.self))
    self.content = content
    self.style = style
  }

  // MARK: Public

  public typealias BehaviorSetter = (_ view: ViewType, _ content: ViewType.Content) -> Void
  public typealias WillDisplay = (_ view: ViewType) -> Void
  public typealias DidDisplay = (_ view: ViewType) -> Void

  /// An optional ID for an alternative style type to use for reuse of this view. Use this to
  /// differentiate between different styling configurations.
  public func alternateStyleID(_ alternateStyleID: AnyHashable?) -> BarModel<ViewType> {
    var copy = self
    copy._alternateStyleID = alternateStyleID
    return copy
  }

  /// An optional closure that sets the view's behavior (such as interaction blocks or delegates).
  /// Called whenever a view is configured with a bar model.
  public func behaviorSetter(_ behaviorSetter: BehaviorSetter?) -> BarModel<ViewType> {
    guard let behaviorSetter = behaviorSetter else { return self }
    var copy = self
    copy._behaviorSetter = { [previous = copy._behaviorSetter] view, content in
      previous?(view, content)
      behaviorSetter(view, content)
    }
    return copy
  }

  /// An optional closure that's called whenever the view is about to display.
  public func willDisplay(_ willDisplay: WillDisplay?) -> BarModel<ViewType> {
    guard let willDisplay = willDisplay else { return self }
    var copy = self
    copy._willDisplay = { [previous = copy._willDisplay] content in
      previous?(content)
      willDisplay(content)
    }
    return copy
  }

  /// An optional closure that's called after the view has been displayed.
  public func didDisplay(_ didDisplay: DidDisplay?) -> BarModel<ViewType> {
    guard let didDisplay = didDisplay else { return self }
    var copy = self
    copy._didDisplay = { [previous = copy._didDisplay] content in
      previous?(content)
      didDisplay(content)
    }
    return copy
  }

  /// Updates the content to the given value.
  public func content(_ content: (inout ViewType.Content) -> Void) -> BarModel<ViewType> {
    var copy = self
    content(&copy.content)
    return copy
  }

  /// Replaces the default closure to construct the view with the given closure.
  public func makeView(_ makeView: @escaping (ViewType.Style) -> ViewType) -> BarModel<ViewType> {
    var copy = self
    copy._makeView = makeView
    return copy
  }

  /// Replaces the default closure to construct the coordinator with the given closure.
  public func makeCoordinator<Coordinator: BarCoordinating>(
    _ makeCoordinator: @escaping (_ update: @escaping (_ animated: Bool) -> Void) -> Coordinator)
    -> Self where
    Coordinator.Model == BarModel<ViewType>
  {
    var copy = self
    copy._makeCoordinator = { AnyBarCoordinator(makeCoordinator($0)) }
    copy.coordinatorType = Coordinator.self
    return copy
  }

  // MARK: Private

  private typealias Coordinator = AnyBarCoordinator<BarModel<ViewType>>

  private let dataID: AnyHashable?
  private var content: ViewType.Content
  private var style: ViewType.Style
  private var _makeView = ViewType.make
  private var _alternateStyleID: AnyHashable?
  private var _behaviorSetter: BehaviorSetter?
  private var _willDisplay: WillDisplay?
  private var _didDisplay: DidDisplay?
  private var coordinatorType: AnyClass = DefaultBarCoordinator<Self>.self
  private var _makeCoordinator: (_ update: @escaping (_ animated: Bool) -> Void) -> Coordinator = {
    AnyBarCoordinator(DefaultBarCoordinator(update: $0))
  }

  private func configure(_ view: ViewType, animated: Bool) {
    view.setContent(content, animated: animated)
  }

  private func castOrAssert(_ view: UIView) -> ViewType? {
    guard let typedView = view as? ViewType else {
      assertionFailure("\(view) is not of the expected type \(ViewType.self)")
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
    let view = _makeView(style)
    configure(view, animated: false)
    _behaviorSetter?(view, content)
    return view
  }

  func configureContent(_ view: UIView, animated: Bool) {
    guard let typedView = castOrAssert(view) else { return }
    configure(typedView, animated: animated)
  }

  func configureBehavior(_ view: UIView) {
    guard let typedView = castOrAssert(view) else { return }
    _behaviorSetter?(typedView, content)
  }

  func isContentEqual(to model: InternalBarModeling) -> Bool {
    guard let model = model as? BarModel<ViewType> else { return false }
    return model.content == content
  }

  func canReuseView(from model: InternalBarModeling) -> Bool {
    guard let model = model as? BarModel<ViewType> else { return false }
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
      assertionFailure("\(coordinator) is not of the expected type \(Coordinator.self)")
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
  public var diffIdentifier: AnyHashable? {
    dataID
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableItem = otherDiffableItem as? BarModel<ViewType> else { return false }
    return isContentEqual(to: otherDiffableItem)
  }
}
