// Created by eric_horacek on 1/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - StyledView

extension StyledView where Self: EpoxyableView {
  /// Constructs a `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other supplementary bars in
  ///     the same section of the same kind.
  ///   - content: The content of the bar view that will be applied to the bar view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the bar view that uniquely identifies.
  /// - Returns: A `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    content: Content,
    behaviors: Behaviors? = nil,
    style: Style)
    -> BarModel<Self>
  {
    BarModel<Self>(
      dataID: dataID,
      params: style,
      content: content,
      makeView: Self.init(style:),
      setContent: { context, content in
        context.view.setContent(content, animated: context.animated)
      })
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}

// MARK: Style == Never

extension StyledView where Self: EpoxyableView, Style == Never {
  /// Constructs a `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other bars in the same bar
  ///     stack.
  ///   - content: The content of the bar view that will be applied to the bar view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: A `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    content: Content,
    behaviors: Behaviors? = nil)
    -> BarModel<Self>
  {
    BarModel<Self>(
      dataID: dataID,
      content: content,
      setContent: { context, content in
        context.view.setContent(content, animated: context.animated)
      })
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}

// MARK: Content == Never

extension StyledView where Self: EpoxyableView, Content == Never {
  /// Constructs a `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other supplementary bars in
  ///     the same section of the same kind.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the bar view that uniquely identifies.
  /// - Returns: A `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    behaviors: Behaviors? = nil,
    style: Style)
    -> BarModel<Self>
  {
    BarModel<Self>(dataID: dataID)
      .styleID(style)
      .makeView { Self(style: style) }
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}

// MARK: Style == Never, Content == Never

extension StyledView where Self: EpoxyableView, Style == Never, Content == Never {
  /// Constructs a `BarModel` with an instance of this view as its bar view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this bar relative to other bars in the same bar
  ///     stack.
  ///   - behaviors: The behaviors that will be applied to the bar view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: A `BarModel` with an instance of this view as its bar view.
  public static func barModel(
    dataID: AnyHashable? = nil,
    behaviors: Behaviors? = nil)
    -> BarModel<Self>
  {
    BarModel<Self>(dataID: dataID)
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}
