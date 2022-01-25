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
    SizingContainer { context in
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
  public static func swiftUIView(
    content: Content,
    behaviors: Behaviors? = nil)
    -> some View
  {
    SizingContainer { context in
      SwiftUIStylelessEpoxyableView<Self>(content: content, behaviors: behaviors, context: context)
    }
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
    SizingContainer { context in
      SwiftUIContentlessEpoxyableView<Self>(style: style, behaviors: behaviors, context: context)
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
  public static func swiftUIView(
    behaviors: Behaviors? = nil)
    -> some View
  {
    SizingContainer { context in
      SwiftUIStylelessContentlessEpoxyableView<Self>(behaviors: behaviors, context: context)
    }
  }
}

// MARK: - SwiftUIEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView`.
private struct SwiftUIEpoxyableView<View: EpoxyableView>: UIViewRepresentable {

  // MARK: Lifecycle

  init(
    content: View.Content,
    style: View.Style,
    behaviors: View.Behaviors? = nil,
    context: SizingContext)
  {
    self.content = content
    self.style = style
    self.behaviors = behaviors
    self.context = context
  }

  // MARK: Internal

  var content: View.Content
  var style: View.Style
  var behaviors: View.Behaviors?
  var context: SizingContext

  func updateUIView(_ wrapper: IdealHeightMeasurementContainer<Self, View>, context: Context) {
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

  func makeUIView(context _: Context) -> IdealHeightMeasurementContainer<Self, View> {
    let uiView = View(style: style)
    uiView.setContent(content, animated: false)
    uiView.setBehaviors(behaviors)
    return IdealHeightMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIStylelessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Style`.
private struct SwiftUIStylelessEpoxyableView<View: EpoxyableView>: UIViewRepresentable
  where
  View.Style == Never
{

  // MARK: Lifecycle

  init(
    content: View.Content,
    behaviors: View.Behaviors? = nil,
    context: SizingContext)
  {
    self.content = content
    self.behaviors = behaviors
    self.context = context
  }

  // MARK: Internal

  var content: View.Content
  var behaviors: View.Behaviors?
  var context: SizingContext

  func updateUIView(_ wrapper: IdealHeightMeasurementContainer<Self, View>, context: Context) {
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

  func makeUIView(context _: Context) -> IdealHeightMeasurementContainer<Self, View> {
    let uiView = View()
    uiView.setContent(content, animated: false)
    uiView.setBehaviors(behaviors)
    return IdealHeightMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Content`.
private struct SwiftUIContentlessEpoxyableView<View: EpoxyableView>: UIViewRepresentable
  where
  View.Content == Never
{

  // MARK: Lifecycle

  init(style: View.Style, behaviors: View.Behaviors? = nil, context: SizingContext) {
    self.style = style
    self.behaviors = behaviors
    self.context = context
  }

  // MARK: Internal

  var style: View.Style
  var behaviors: View.Behaviors?
  var context: SizingContext

  func updateUIView(_ wrapper: IdealHeightMeasurementContainer<Self, View>, context _: Context) {
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

  func makeUIView(context _: Context) -> IdealHeightMeasurementContainer<Self, View> {
    let uiView = View(style: style)
    uiView.setBehaviors(behaviors)
    return IdealHeightMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIStylelessContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Style` and `Content`.
private struct SwiftUIStylelessContentlessEpoxyableView<View: EpoxyableView>: UIViewRepresentable {

  // MARK: Lifecycle

  init(behaviors: View.Behaviors? = nil, context: SizingContext) {
    self.behaviors = behaviors
    self.context = context
    self.context = context
  }

  // MARK: Internal

  var behaviors: View.Behaviors?
  var context: SizingContext

  func updateUIView(_ wrapper: IdealHeightMeasurementContainer<Self, View>, context _: Context) {
    wrapper.view = self
    wrapper.uiView.setBehaviors(behaviors)
  }

  func makeUIView(context _: Context) -> IdealHeightMeasurementContainer<Self, View> {
    let uiView = View()
    uiView.setBehaviors(behaviors)
    return IdealHeightMeasurementContainer(view: self, uiView: uiView, context: context)
  }
}
