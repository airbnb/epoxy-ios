// Created by eric_horacek on 9/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - StyledView

extension StyledView where Self: ContentConfigurableView & BehaviorsConfigurableView {
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  public static func swiftUIView(
    content: Content,
    style: Style,
    behaviors: Behaviors? = nil)
    -> some View
  {
    SwiftUIEpoxyableView<Self>(content: content, style: style, behaviors: behaviors)
  }
}

extension StyledView
  where
  Self: ContentConfigurableView & BehaviorsConfigurableView,
  Style == Never
{
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  public static func swiftUIView(
    content: Content,
    behaviors: Behaviors? = nil)
    -> some View
  {
    SwiftUIStylelessEpoxyableView<Self>(content: content, behaviors: behaviors)
  }
}

extension StyledView
  where
  Self: ContentConfigurableView & BehaviorsConfigurableView,
  Content == Never
{
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  public static func swiftUIView(
    style: Style,
    behaviors: Behaviors? = nil)
    -> some View
  {
    SwiftUIContentlessEpoxyableView<Self>(style: style, behaviors: behaviors)
  }
}

extension StyledView
  where
  Self: ContentConfigurableView & BehaviorsConfigurableView,
  Content == Never,
  Style == Never
{
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  public static func swiftUIView(
    behaviors: Behaviors? = nil)
    -> some View
  {
    SwiftUIStylelessContentlessEpoxyableView<Self>(behaviors: behaviors)
  }
}

// MARK: - SwiftUIEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView`.
struct SwiftUIEpoxyableView<View: EpoxyableView>: UIViewRepresentable {

  // MARK: Lifecycle

  init(content: View.Content, style: View.Style, behaviors: View.Behaviors? = nil) {
    self.content = content
    self.style = style
    self.behaviors = behaviors
  }

  // MARK: Internal

  var content: View.Content
  var style: View.Style
  var behaviors: View.Behaviors?

  func updateUIView(_ wrapper: EpoxyableViewContainer<Self, View>, context: Context) {
    let animated = context.transaction.animation != nil

    defer {
      wrapper.view = self

      // We always update the view behaviors on every view update.
      wrapper.uiView.setBehaviors(behaviors)
    }

    // We need to create a new view instance when the style is updated.
    guard wrapper.view.style == style else {
      let uiView = View(style: style)
      uiView.setContent(content, animated: false)
      uiView.setBehaviors(behaviors)
      wrapper.uiView = uiView
      return
    }

    // We need to update the content of the existing view when the content is updated.
    guard wrapper.view.content == content else {
      wrapper.uiView.setContent(content, animated: animated)
      wrapper.invalidateIntrinsicContentSize()
      return
    }

    // No updates required.
  }

  func makeUIView(context: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View(style: style)
    uiView.setContent(content, animated: false)
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView)
  }
}

// MARK: - SwiftUIStylelessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Style`.
struct SwiftUIStylelessEpoxyableView<View: EpoxyableView>: UIViewRepresentable where View.Style == Never {

  // MARK: Lifecycle

  init(content: View.Content, behaviors: View.Behaviors? = nil) {
    self.content = content
    self.behaviors = behaviors
  }

  // MARK: Internal

  var content: View.Content
  var behaviors: View.Behaviors?

  func updateUIView(_ wrapper: EpoxyableViewContainer<Self, View>, context: Context) {
    let animated = context.transaction.animation != nil

    defer {
      wrapper.view = self

      // We always update the view behaviors on every view update.
      wrapper.uiView.setBehaviors(behaviors)
    }

    // We need to update the content of the existing view when the content is updated.
    guard wrapper.view.content == content else {
      wrapper.uiView.setContent(content, animated: animated)
      wrapper.invalidateIntrinsicContentSize()
      return
    }

    // No updates required.
  }

  func makeUIView(context: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View()
    uiView.setContent(content, animated: false)
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView)
  }
}

// MARK: - SwiftUIContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Content`.
struct SwiftUIContentlessEpoxyableView<View: EpoxyableView>: UIViewRepresentable where View.Content == Never {

  // MARK: Lifecycle

  init(style: View.Style, behaviors: View.Behaviors? = nil) {
    self.style = style
    self.behaviors = behaviors
  }

  // MARK: Internal

  var style: View.Style
  var behaviors: View.Behaviors?

  func updateUIView(_ wrapper: EpoxyableViewContainer<Self, View>, context: Context) {
    defer {
      wrapper.view = self

      // We always update the view behaviors on every view update.
      wrapper.uiView.setBehaviors(behaviors)
    }

    // We need to create a new view instance when the style is updated.
    guard wrapper.view.style == style else {
      let uiView = View(style: style)
      uiView.setBehaviors(behaviors)
      wrapper.uiView = uiView
      return
    }

    // No updates required.
  }

  func makeUIView(context: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View(style: style)
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView)
  }
}

// MARK: - SwiftUIStylelessContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Style` and `Content`.
struct SwiftUIStylelessContentlessEpoxyableView<View: EpoxyableView>: UIViewRepresentable {

  // MARK: Lifecycle

  init(behaviors: View.Behaviors? = nil) {
    self.behaviors = behaviors
  }

  // MARK: Internal

  var behaviors: View.Behaviors?

  func updateUIView(_ wrapper: EpoxyableViewContainer<Self, View>, context: Context) {
    wrapper.view = self
    wrapper.uiView.setBehaviors(behaviors)
  }

  func makeUIView(context: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View()
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView)
  }
}

// MARK: - EpoxyableViewContainer

/// A view that has an `intrinsicContentSize` of the `view`'s `systemLayoutSizeFitting(…)`.
final class EpoxyableViewContainer<SwiftUIView: UIViewRepresentable, UIViewType: EpoxyableView>: UIView {

  // MARK: Lifecycle

  init(view: SwiftUIView, uiView: UIViewType) {
    self.view = view
    self.uiView = uiView

    super.init(frame: .zero)

    addSubview(uiView)
    setUpConstraints()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var view: SwiftUIView

  var uiView: UIViewType {
    didSet { updateView(from: oldValue) }
  }

  override var intrinsicContentSize: CGSize {
    uiView.systemLayoutSizeFitting(
      UIViewType.layoutFittingCompressedSize,
      withHorizontalFittingPriority: .fittingSizeLevel,
      verticalFittingPriority: .fittingSizeLevel)
  }

  // MARK: Private

  private func updateView(from oldValue: UIViewType) {
    guard uiView !== oldValue else { return }
    oldValue.removeFromSuperview()
    addSubview(uiView)
    setUpConstraints()
    invalidateIntrinsicContentSize()
  }

  private func setUpConstraints() {
    uiView.translatesAutoresizingMaskIntoConstraints = false

    let leading = uiView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let top = uiView.topAnchor.constraint(equalTo: topAnchor)

    let trailing = uiView.trailingAnchor.constraint(equalTo: trailingAnchor)
    trailing.priority = .defaultHigh

    let bottom = uiView.bottomAnchor.constraint(equalTo: bottomAnchor)
    bottom.priority = .defaultHigh

    NSLayoutConstraint.activate([leading, top, trailing, bottom])
  }
}
