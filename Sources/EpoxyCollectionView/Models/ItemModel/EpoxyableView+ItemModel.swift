// Created by eric_horacek on 1/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - StyledView

extension StyledView where Self: EpoxyableView {
  /// Constructs an `ItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the same
  ///     section.
  ///   - content: The content of the item view that will be applied to the item view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the item view that uniquely identifies.
  /// - Returns: An `ItemModel` with an instance of this view as its item view.
  public static func itemModel(
    dataID: AnyHashable,
    content: Content,
    behaviors: Behaviors = .init(),
    style: Style)
    -> ItemModel<Self, Content>
  {
    ItemModel<Self, Content>(
      dataID: dataID,
      params: style,
      content: content,
      makeView: Self.init(style:),
      configureView: { context in
        context.view.setContent(context.content, animated: context.animated)
      })
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}

// MARK: Style == EmptyStyle

extension StyledView where Self: EpoxyableView, Style == EmptyStyle {
  /// Constructs an `ItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the same
  ///     section.
  ///   - content: The content of the item view that will be applied to the item view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: An `ItemModel` with an instance of this view as its item view.
  public static func itemModel(
    dataID: AnyHashable,
    content: Content,
    behaviors: Behaviors = .init())
    -> ItemModel<Self, Content>
  {
    itemModel(dataID: dataID, content: content, behaviors: behaviors, style: .shared)
  }
}

// MARK: Content == EmptyContent

extension StyledView where Self: EpoxyableView, Content == EmptyContent {
  /// Constructs an `ItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the same
  ///     section.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the item view that uniquely identifies.
  /// - Returns: An `ItemModel` with an instance of this view as its item view.
  public static func itemModel(
    dataID: AnyHashable,
    behaviors: Behaviors = .init(),
    style: Style)
    -> ItemModel<Self, Content>
  {
    itemModel(dataID: dataID, content: .shared, behaviors: behaviors, style: style)
  }
}

// MARK: Style == EmptyStyle, Content == EmptyContent

extension StyledView where Self: EpoxyableView, Style == EmptyStyle, Content == EmptyContent {
  /// Constructs an `ItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the same
  ///     section.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: An `ItemModel` with an instance of this view as its item view.
  public static func itemModel(
    dataID: AnyHashable,
    behaviors: Behaviors = .init())
    -> ItemModel<Self, Content>
  {
    itemModel(dataID: dataID, content: .shared, behaviors: behaviors, style: .shared)
  }
}
