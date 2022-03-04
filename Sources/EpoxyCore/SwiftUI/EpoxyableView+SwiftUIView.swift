// Created by eric_horacek on 9/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - StyledView

extension StyledView where Self: ContentConfigurableView & BehaviorsConfigurableView {
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  ///
  /// To perform additional configuration of the `EpoxyableView` instance, call `configure` on the
  /// returned SwiftUI `View`:
  /// ```
  /// MyView.swiftUIView(…)
  ///   .configure { (view: MyView) in
  ///     …
  ///   }
  /// ```
  public static func swiftUIView(
    content: Content,
    style: Style,
    behaviors: Behaviors? = nil,
    sizing: SwiftUISizingContainerConfiguration = .init())
    -> SwiftUISizingContainer<SwiftUIEpoxyableView<Self>>
  {
    SwiftUISizingContainer(configuration: sizing) { context in
      SwiftUIEpoxyableView<Self>(
        content: content,
        style: style,
        behaviors: behaviors,
        context: context)
    }
  }
}

extension StyledView
  where
  Self: ContentConfigurableView & BehaviorsConfigurableView,
  Style == Never
{
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  ///
  /// To perform additional configuration of the `EpoxyableView` instance, call `configure` on the
  /// returned SwiftUI `View`:
  /// ```
  /// MyView.swiftUIView(…)
  ///   .configure { (view: MyView) in
  ///     …
  ///   }
  /// ```
  public static func swiftUIView(
    content: Content,
    behaviors: Behaviors? = nil,
    sizing: SwiftUISizingContainerConfiguration = .init())
    -> SwiftUISizingContainer<SwiftUIStylelessEpoxyableView<Self>>
  {
    SwiftUISizingContainer(configuration: sizing) { context in
      SwiftUIStylelessEpoxyableView<Self>(
        content: content,
        behaviors: behaviors,
        context: context)
    }
  }
}

extension StyledView
  where
  Self: ContentConfigurableView & BehaviorsConfigurableView,
  Content == Never
{
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  ///
  /// To perform additional configuration of the `EpoxyableView` instance, call `configure` on the
  /// returned SwiftUI `View`:
  /// ```
  /// MyView.swiftUIView(…)
  ///   .configure { (view: MyView) in
  ///     …
  ///   }
  /// ```
  public static func swiftUIView(
    style: Style,
    behaviors: Behaviors? = nil,
    sizing: SwiftUISizingContainerConfiguration = .init())
    -> SwiftUISizingContainer<SwiftUIContentlessEpoxyableView<Self>>
  {
    SwiftUISizingContainer(configuration: sizing) { context in
      SwiftUIContentlessEpoxyableView<Self>(
        style: style,
        behaviors: behaviors,
        context: context)
    }
  }
}

extension StyledView
  where
  Self: ContentConfigurableView & BehaviorsConfigurableView,
  Content == Never,
  Style == Never
{
  /// Returns a SwiftUI `View` representing this `EpoxyableView`.
  ///
  /// To perform additional configuration of the `EpoxyableView` instance, call `configure` on the
  /// returned SwiftUI `View`:
  /// ```
  /// MyView.swiftUIView(…)
  ///   .configure { (view: MyView) in
  ///     …
  ///   }
  /// ```
  public static func swiftUIView(
    behaviors: Behaviors? = nil,
    sizing: SwiftUISizingContainerConfiguration = .init())
    -> SwiftUISizingContainer<SwiftUIStylelessContentlessEpoxyableView<Self>>
  {
    SwiftUISizingContainer(configuration: sizing) { context in
      SwiftUIStylelessContentlessEpoxyableView<Self>(behaviors: behaviors, context: context)
    }
  }
}

// MARK: - SwiftUIEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with content, behaviors, and style.
public struct SwiftUIEpoxyableView<View>: UIViewRepresentable, UIViewConfiguringSwiftUIView
  where
  View: EpoxyableView
{
  var content: View.Content
  var style: View.Style
  var behaviors: View.Behaviors?
  var context: SwiftUISizingContext
  public var configurations: [(View) -> Void] = []

  public func updateUIView(_ wrapper: SwiftUIMeasurementContainer<Self, View>, context: Context) {
    let animated = context.transaction.animation != nil

    defer {
      wrapper.view = self

      // We always update the view behaviors on every view update.
      wrapper.uiView.setBehaviors(behaviors)

      for configuration in configurations {
        configuration(wrapper.uiView)
      }
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

  public func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Self, View> {
    let uiView = View(style: style)
    uiView.setContent(content, animated: false)
    // No need to set behaviors as `updateUIView` is called immediately after construction.
    return SwiftUIMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIStylelessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Style`.
public struct SwiftUIStylelessEpoxyableView<View>: UIViewRepresentable, UIViewConfiguringSwiftUIView
  where
  View: EpoxyableView,
  View.Style == Never
{
  var content: View.Content
  var behaviors: View.Behaviors?
  var context: SwiftUISizingContext
  public var configurations: [(View) -> Void] = []

  public func updateUIView(_ wrapper: SwiftUIMeasurementContainer<Self, View>, context: Context) {
    let animated = context.transaction.animation != nil

    defer {
      wrapper.view = self

      // We always update the view behaviors on every view update.
      wrapper.uiView.setBehaviors(behaviors)

      for configuration in configurations {
        configuration(wrapper.uiView)
      }
    }

    // We need to update the content of the existing view when the content is updated.
    guard wrapper.view.content == content else {
      wrapper.uiView.setContent(content, animated: animated)
      wrapper.invalidateIntrinsicContentSize()
      return
    }

    // No updates required.
  }

  public func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Self, View> {
    let uiView = View()
    uiView.setContent(content, animated: false)
    // No need to set behaviors as `updateUIView` is called immediately after construction.
    return SwiftUIMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Content`.
public struct SwiftUIContentlessEpoxyableView<View>: UIViewRepresentable, UIViewConfiguringSwiftUIView
  where
  View: EpoxyableView,
  View.Content == Never
{
  var style: View.Style
  var behaviors: View.Behaviors?
  var context: SwiftUISizingContext
  public var configurations: [(View) -> Void] = []

  public func updateUIView(_ wrapper: SwiftUIMeasurementContainer<Self, View>, context _: Context) {
    defer {
      wrapper.view = self

      // We always update the view behaviors on every view update.
      wrapper.uiView.setBehaviors(behaviors)

      for configuration in configurations {
        configuration(wrapper.uiView)
      }
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

  public func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Self, View> {
    let uiView = View(style: style)
    // No need to set behaviors as `updateUIView` is called immediately after construction.
    return SwiftUIMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIStylelessContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Style` and `Content`.
public struct SwiftUIStylelessContentlessEpoxyableView<View>: UIViewRepresentable, UIViewConfiguringSwiftUIView
  where
  View: EpoxyableView,
  View.Content == Never,
  View.Style == Never
{
  public var configurations: [(View) -> Void] = []
  var behaviors: View.Behaviors?
  var context: SwiftUISizingContext

  public func updateUIView(_ wrapper: SwiftUIMeasurementContainer<Self, View>, context _: Context) {
    wrapper.view = self
    wrapper.uiView.setBehaviors(behaviors)

    for configuration in configurations {
      configuration(wrapper.uiView)
    }
  }

  public func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Self, View> {
    let uiView = View()
    // No need to set behaviors as `updateUIView` is called immediately after construction.
    return SwiftUIMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}
