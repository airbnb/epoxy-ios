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
    IdealHeightContainer { context in
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
    IdealHeightContainer { context in
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
    IdealHeightContainer { context in
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
    IdealHeightContainer { context in
      SwiftUIStylelessContentlessEpoxyableView<Self>(behaviors: behaviors, context: context)
    }
  }
}

// MARK: - IdealHeightContainer

/// A container with content that dictates its ideal height given its geometry.
///
/// TODO: We can eventually expand this concept to support ideal widths if we'd like.
private struct IdealHeightContainer<Content: View>: View {
  var content: (IdealHeightContainerContext) -> Content

  var body: some View {
    GeometryReader { proxy in
      content(.init(initialSize: proxy.size, idealHeight: $idealHeight))
    }
    // Pass the ideal height as the max height to ensure this view doesn't get stretched vertically.
    .frame(idealHeight: idealHeight, maxHeight: idealHeight)
  }

  /// With start with 150 as our "estimated" size. We will resolve to a final size asynchronously
  /// after measurement.
  @State private var idealHeight: CGFloat = 150
}

// MARK: - IdealHeightContainerContext

/// The context available to content of an `IdealHeightContainer`
private struct IdealHeightContainerContext {
  var initialSize: CGSize
  var idealHeight: Binding<CGFloat>
}

// MARK: - SwiftUIEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView`.
private struct SwiftUIEpoxyableView<View: EpoxyableView>: UIViewRepresentable {

  // MARK: Lifecycle

  init(
    content: View.Content,
    style: View.Style,
    behaviors: View.Behaviors? = nil,
    context: IdealHeightContainerContext)
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
  var context: IdealHeightContainerContext

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

  func makeUIView(context _: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View(style: style)
    uiView.setContent(content, animated: false)
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView, context: context)
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
    context: IdealHeightContainerContext)
  {
    self.content = content
    self.behaviors = behaviors
    self.context = context
  }

  // MARK: Internal

  var content: View.Content
  var behaviors: View.Behaviors?
  var context: IdealHeightContainerContext

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

  func makeUIView(context _: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View()
    uiView.setContent(content, animated: false)
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Content`.
private struct SwiftUIContentlessEpoxyableView<View: EpoxyableView>: UIViewRepresentable
  where
  View.Content == Never
{

  // MARK: Lifecycle

  init(style: View.Style, behaviors: View.Behaviors? = nil, context: IdealHeightContainerContext) {
    self.style = style
    self.behaviors = behaviors
    self.context = context
  }

  // MARK: Internal

  var style: View.Style
  var behaviors: View.Behaviors?
  var context: IdealHeightContainerContext

  func updateUIView(_ wrapper: EpoxyableViewContainer<Self, View>, context _: Context) {
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

  func makeUIView(context _: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View(style: style)
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - SwiftUIStylelessContentlessEpoxyableView

/// A SwiftUI `View` representing an `EpoxyableView` with a `Never` `Style` and `Content`.
private struct SwiftUIStylelessContentlessEpoxyableView<View: EpoxyableView>: UIViewRepresentable {

  // MARK: Lifecycle

  init(behaviors: View.Behaviors? = nil, context: IdealHeightContainerContext) {
    self.behaviors = behaviors
    self.context = context
    self.context = context
  }

  // MARK: Internal

  var behaviors: View.Behaviors?
  var context: IdealHeightContainerContext

  func updateUIView(_ wrapper: EpoxyableViewContainer<Self, View>, context _: Context) {
    wrapper.view = self
    wrapper.uiView.setBehaviors(behaviors)
  }

  func makeUIView(context _: Context) -> EpoxyableViewContainer<Self, View> {
    let uiView = View()
    uiView.setBehaviors(behaviors)
    return EpoxyableViewContainer(view: self, uiView: uiView, context: context)
  }
}

// MARK: - EpoxyableViewContainer

/// A view that has an `intrinsicContentSize` of the `view`'s `systemLayoutSizeFitting(…)`.
private final class EpoxyableViewContainer<SwiftUIView, UIViewType>: UIView
  where
  SwiftUIView: UIViewRepresentable,
  UIViewType: EpoxyableView
{

  // MARK: Lifecycle

  init(view: SwiftUIView, uiView: UIViewType, context: IdealHeightContainerContext) {
    self.view = view
    self.uiView = uiView
    self.context = context
    super.init(frame: .zero)

    addSubview(uiView)
    setUpConstraints()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var view: SwiftUIView

  var uiView: UIViewType {
    didSet { updateView(from: oldValue) }
  }

  override var intrinsicContentSize: CGSize {
    if let size = latestMeasuredSize {
      return size
    }

    return measureView()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    // We need to re-measure the view whenever the size of the bounds change, as the previous size
    // will be incorrect.
    if bounds.size != latestMeasurementBoundsSize {
      measureView()
    }
  }

  // MARK: Private

  private let context: IdealHeightContainerContext

  /// The bounds size at the time of the latest measurement.
  ///
  /// Used to ensure we don't do extraneous measurements if the bounds haven't changed.
  private var latestMeasurementBoundsSize: CGSize?

  /// The most recently measured intrinsic content size of the `uiView`, else `nil` if it has not
  /// yet been measured.
  private var latestMeasuredSize: CGSize? = nil {
    didSet {
      guard oldValue != latestMeasuredSize else { return }
      invalidateIntrinsicContentSize()
    }
  }

  private func updateView(from oldValue: UIViewType) {
    guard uiView !== oldValue else { return }
    oldValue.removeFromSuperview()
    addSubview(uiView)
    setUpConstraints()
    setNeedsLayout()
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

  /// Measures the `uiView`, returning the resulting size and storing it in `latestMeasuredSize`.
  @discardableResult
  private func measureView() -> CGSize {
    // On the first layout, use the `initialSize` to measure with a reasonable first attempt, as
    // passing zero results in unusable sizes and also upsets SwiftUI.
    let measurementBounds = bounds.size == .zero ? context.initialSize : bounds.size
    latestMeasurementBoundsSize = measurementBounds

    let targetSize = CGSize(
      width: measurementBounds.width,
      height: UIViewType.layoutFittingCompressedSize.height)

    let fittingSize = uiView.systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .defaultHigh,
      verticalFittingPriority: .fittingSizeLevel)

    let measuredSize = CGSize(width: UIView.noIntrinsicMetric, height: fittingSize.height)

    // We need to update the ideal height async otherwise we'll get the "Modifying state during view
    // update, which will cause undefined behavior" runtime warning as the view's intrinsic content
    // size is queried during the view update phase.
    DispatchQueue.main.async { [idealHeight = context.idealHeight] in
      idealHeight.wrappedValue = measuredSize.height
    }

    latestMeasuredSize = measuredSize

    return measuredSize
  }
}
