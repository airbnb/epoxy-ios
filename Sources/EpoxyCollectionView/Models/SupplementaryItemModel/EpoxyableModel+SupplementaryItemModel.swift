// Created by eric_horacek on 1/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - StyledView

extension StyledView where Self: EpoxyableView {
  /// Constructs a `SupplementaryItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other supplementary items in
  ///     the same section of the same kind.
  ///   - content: The content of the item view that will be applied to the item view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the item view that uniquely identifies.
  /// - Returns: An `SupplementaryItemModel` with an instance of this view as its item view.
  public static func supplementaryItemModel(
    dataID: AnyHashable,
    content: Content,
    behaviors: Behaviors = .init(),
    style: Style)
    -> SupplementaryItemModel<Self, Content>
  {
    SupplementaryItemModel<Self, Content>(
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
  /// Constructs a `SupplementaryItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other supplementary items in
  ///     the same section of the same kind.
  ///   - content: The content of the item view that will be applied to the item view via the
  ///     `setContent(_:animated:)` method whenever the content has changed.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: An `SupplementaryItemModel` with an instance of this view as its item view.
  public static func supplementaryItemModel(
    dataID: AnyHashable,
    content: Content,
    behaviors: Behaviors = .init())
    -> SupplementaryItemModel<Self, Content>
  {
    supplementaryItemModel(dataID: dataID, content: content, behaviors: behaviors, style: .shared)
  }
}

// MARK: Content == EmptyContent

extension StyledView where Self: EpoxyableView, Content == EmptyContent {
  /// Constructs a `SupplementaryItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other supplementary items in
  ///     the same section of the same kind.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  ///   - style: The style of the item view that uniquely identifies.
  /// - Returns: An `SupplementaryItemModel` with an instance of this view as its item view.
  public static func supplementaryItemModel(
    dataID: AnyHashable,
    behaviors: Behaviors = .init(),
    style: Style)
    -> SupplementaryItemModel<Self, Content>
  {
    supplementaryItemModel(dataID: dataID, content: .shared, behaviors: behaviors, style: style)
  }
}

// MARK: Style == EmptyStyle, Content == EmptyContent

extension StyledView where Self: EpoxyableView, Style == EmptyStyle, Content == EmptyContent {
  /// Constructs a `SupplementaryItemModel` with an instance of this view as its item view.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other supplementary items in
  ///     the same section of the same kind.
  ///   - behaviors: The behaviors that will be applied to the item view via the `setBehaviors(_:)`
  ///     method whenever this model is updated. Defaults to no behaviors.
  /// - Returns: An `SupplementaryItemModel` with an instance of this view as its item view.
  public static func supplementaryItemModel(
    dataID: AnyHashable,
    behaviors: Behaviors = .init())
    -> SupplementaryItemModel<Self, Content>
  {
    supplementaryItemModel(dataID: dataID, content: .shared, behaviors: behaviors, style: .shared)
  }
}
