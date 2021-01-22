// Created by eric_horacek on 1/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - StyledView

extension StyledView where Self: EpoxyableView {
  /// Constructs an `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other supplementary bars in
  ///     the same section of the same kind.
  ///   - content: The content of the bar view that will be applied to the bar view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the bar view that uniquely identifies.
  /// - Returns: An `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    content: Content,
    behaviors: Behaviors = .init(),
    style: Style)
    -> BarModel<Self, Content>
  {
    BarModel<Self, Content>(
      dataID: dataID,
      params: style,
      content: content,
      makeView: Self.init(style:),
      setContent: { context in
        context.view.setContent(context.content, animated: context.animated)
      })
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}

// MARK: Style == EmptyStyle

extension StyledView where Self: EpoxyableView, Style == EmptyStyle {
  /// Constructs an `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other bars in the same bar
  ///     stack.
  ///   - content: The content of the bar view that will be applied to the bar view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: An `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    content: Content,
    behaviors: Behaviors = .init())
    -> BarModel<Self, Content>
  {
    barModel(dataID: dataID, content: content, behaviors: behaviors, style: .shared)
  }
}

// MARK: Content == EmptyContent

extension StyledView where Self: EpoxyableView, Content == EmptyContent {
  /// Constructs an `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other supplementary bars in
  ///     the same section of the same kind.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the bar view that uniquely identifies.
  /// - Returns: An `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    behaviors: Behaviors = .init(),
    style: Style)
    -> BarModel<Self, Content>
  {
    barModel(dataID: dataID, content: .shared, behaviors: behaviors, style: style)
  }
}

// MARK: Style == EmptyStyle, Content == EmptyContent

extension StyledView where Self: EpoxyableView, Style == EmptyStyle, Content == EmptyContent {
  /// Constructs an `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other bars in the same bar
  ///     stack.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: An `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    behaviors: Behaviors = .init())
    -> BarModel<Self, Content>
  {
    barModel(dataID: dataID, content: .shared, behaviors: behaviors, style: .shared)
  }
}
