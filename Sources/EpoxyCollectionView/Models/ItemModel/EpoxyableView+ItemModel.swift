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
    behaviors: Behaviors? = nil,
    style: Style)
    -> ItemModel<Self>
  {
    ItemModel<Self>(
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
    behaviors: Behaviors? = nil)
    -> ItemModel<Self>
  {
    ItemModel<Self>(
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
    behaviors: Behaviors? = nil,
    style: Style)
    -> ItemModel<Self>
  {
    ItemModel<Self>(dataID: dataID)
      .styleID(style)
      .makeView { Self(style: style) }
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}

// MARK: Style == Never, Content == Never

extension StyledView where Self: EpoxyableView, Style == Never, Content == Never {
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
    behaviors: Behaviors? = nil)
    -> ItemModel<Self>
  {
    ItemModel<Self>(dataID: dataID)
      .setBehaviors { context in
        context.view.setBehaviors(behaviors)
      }
  }
}
