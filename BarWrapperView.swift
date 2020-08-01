// Created by eric_horacek on 3/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - BarWrapperView

/// A wrapper of a single bar view that supports animatedly updating its bar model.
///
/// Cannot have a `CATransformLayer` as its layer class as that prevents usage of the
/// `UIView.transition` APIs for swapping its contents.
final class BarWrapperView: UIView {

  // MARK: Lifecycle

  init(
    zOrder: BarStackView.ZOrder,
    willDisplayBar: ((_ bar: UIView) -> Void)? = nil,
    didUpdateCoordinator: ((AnyBarCoordinating) -> Void)? = nil)
  {
    self.zOrder = zOrder
    self.willDisplayBar = willDisplayBar
    self.didUpdateCoordinator = didUpdateCoordinator
    super.init(frame: .zero)
    layoutMargins = .zero
    translatesAutoresizingMaskIntoConstraints = false
    // Allow this view to be overlapped by the safe area.
    insetsLayoutMarginsFromSafeArea = false
    // Ensure that the view original safe area insets can inset the content of a bar.
    preservesSuperviewLayoutMargins = true
    // Ensure that the bar container's children are focused together.
    shouldGroupAccessibilityChildren = true
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    guard let view = view else { return }

    let margins: UIEdgeInsets
    if let originalMargins = originalViewLayoutMargins {
      margins = originalMargins
    } else {
      margins = view.layoutMargins
      originalViewLayoutMargins = margins
    }

    let layoutBehavior = (view as? SafeAreaLayoutMarginsBarView)?.preferredSafeAreaLayoutMarginsBehavior ?? .max
    switch layoutBehavior {
    case .max:
      view.layoutMargins.top = max(layoutMargins.top, margins.top)
      view.layoutMargins.bottom = max(layoutMargins.bottom, margins.bottom)
    case .sum:
      view.layoutMargins.top = layoutMargins.top + margins.top
      view.layoutMargins.bottom = layoutMargins.bottom + margins.bottom
    }
  }

  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let view = super.hitTest(point, with: event) else { return nil }

    // This view should never receive touches, but since it can contain interactive elements we
    // need to ignore them via a hit test, not `isUserInteractionEnabled`.
    return view === self ? nil : view
  }

  public override func layoutMarginsDidChange() {
    super.layoutMarginsDidChange()
    setNeedsLayout()
  }

  // MARK: Internal

  /// The current bar model.
  var model: BarModeling?

  /// The current bar coordinator.
  public var coordinator: AnyBarCoordinating? {
    _coordinator?.backing
  }

  /// The current bar view.
  private(set) var view: UIView? {
    didSet { updateView(from: oldValue) }
  }

  /// Updates the bar model the given bar model.
  func setModel(_ model: BarModeling?, animated: Bool) {
    self.model = model
    setModel(model?.internalBarModel, animated: animated)
  }

  // MARK: Private

  private let zOrder: BarStackView.ZOrder

  /// The current bar model.
  private var _model: InternalBarModeling?

  /// The coordinator wrapper: a type-erased `AnyBarCoordinator`.
  private var _coordinator: AnyBarCoordinating?

  /// A closure that will be invoked prior to adding the bar view to the view hierarchy.
  private let willDisplayBar: ((_ bar: UIView) -> Void)?

  /// A closure that's called after the coordinator has been created.
  private let didUpdateCoordinator: ((_ coordinator: AnyBarCoordinating) -> Void)?

  /// The original bottom layout margins of the bar before they were overridden by this view's
  /// layout margins.
  private var originalViewLayoutMargins: UIEdgeInsets?

  private func setModel(_ model: InternalBarCoordinating?, animated: Bool) {
    let oldValue = _model

    guard let originalModel = model else {
      view?.removeFromSuperview()
      view = nil
      _coordinator = nil
      return
    }

    let coordinator = self.coordinator(for: originalModel)

    guard let model = originalModel.barModel(for: coordinator).internalBarModel as? InternalBarModeling else {
      assertionFailure("""
      Unable to extract an InternalBarModeling from \(originalModel), nesting BarModeling models
      deeper than two layers is not supported
      """)
      return
    }

    _model = model

    if let oldValue = oldValue, let view = view, oldValue.canReuseView(from: model) {
      if !oldValue.isContentEqual(to: model) {
        model.configureContent(view, animated: animated)
      }
      // The behavior is configured regardless of content equality sice behavior is not equatable.
      model.configureBehavior(view)
    } else {
      let view = makeView(from: model)
      let animations = { self.view = view }
      if animated {
        // We do not allow consumers to pass in this duration as they can configure it by wrapping
        // this call in their own animation transaction that will override this one.
        UIView.transition(
          with: self,
          duration: 0.3,
          options: .transitionCrossDissolve,
          animations: animations,
          completion: { _ in
            model.didDisplay(view)
          })
      } else {
        animations()
        model.didDisplay(view)
      }
    }
  }

  private func makeView(from model: InternalBarModeling) -> UIView {
    let view = model.makeConfiguredView()
    willDisplayBar?(view)
    model.willDisplay(view)
    originalViewLayoutMargins = nil
    return view
  }

  private func coordinator(for model: InternalBarCoordinating) -> AnyBarCoordinating {
    if let coordinator = _coordinator, model.canReuseCoordinator(coordinator) {
      return coordinator
    }

    var canUpdate = false
    let coordinator = model.makeCoordinator(update: { [weak self] animated in
      guard canUpdate, let self = self else { return }
      // We pass the original model here so we don't stack coordinator models atop one another.
      self.setModel(self.model, animated: animated)
    })

    _coordinator = coordinator
    didUpdateCoordinator?(coordinator.backing)

    // Calling out to `didUpdateCoordinator` can have a side-effect of configuring properties of the
    // coordinator that may trigger an `updateBarModel` to be called. We want to wait to perform
    // them all at once when we query the bar model from the coordinator after this method returns.
    canUpdate = true

    return coordinator
  }

  private func updateView(from oldValue: UIView?) {
    guard view !== oldValue else { return }

    oldValue?.removeFromSuperview()

    if let view = view {
      view.translatesAutoresizingMaskIntoConstraints = false
      view.insetsLayoutMarginsFromSafeArea = false
      addSubview(view)
      switch zOrder {
      case .bottomToTop:
        view.constrainToSuperview(anchors: [.leading, .top, .trailing])
        let constraint = view.bottomAnchor.constraint(equalTo: bottomAnchor)
        // Ensure that when compressed the bar slides underneath the previous bar or the edge of the
        // screen rather than compressing its content which can result in weird layouts.
        //
        // We add one to `defaultLow` to allow for content to use this as its compression resistance
        // priority to be compressed.
        constraint.priority = UILayoutPriority(rawValue: UILayoutPriority.defaultLow.rawValue + 1)
        constraint.isActive = true
      case .topToBottom:
        view.constrainToSuperview(anchors: [.leading, .bottom, .trailing])
        let constraint = view.topAnchor.constraint(equalTo: topAnchor)
        // Ensure that when compressed the bar slides underneath the previous bar or the edge of the
        // screen rather than compressing its content which can result in weird layouts.
        //
        // We add one to `defaultLow` to allow for content to use this as its compression resistance
        // priority to be compressed.
        constraint.priority = UILayoutPriority(rawValue: UILayoutPriority.defaultLow.rawValue + 1)
        constraint.isActive = true
      }
    }
  }

}
