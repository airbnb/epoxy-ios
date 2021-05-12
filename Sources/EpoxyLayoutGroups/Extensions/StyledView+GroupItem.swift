// Created by Tyler Hedrick on 3/23/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

extension StyledView where Self: EpoxyableView {
  /// Produces an item to be used within a Group
  /// - Parameters:
  ///   - dataID: the unique identifier for this item
  ///   - content: the content for this item's view
  ///   - behaviors: the behaviors for the view
  ///   - style: the style for the view
  /// - Returns: a group item model representing the view
  public static func groupItem(
    dataID: AnyHashable,
    content: Content,
    behaviors: Behaviors? = nil,
    style: Style)
  -> GroupItem<Self>
  {
    GroupItem<Self>(
      dataID: dataID,
      content: content,
      make: { Self(style: style) },
      setContent: { context, content in
        context.constrainable.setContent(content, animated: context.animated)
      })
      .setBehaviors { context in
        context.constrainable.setBehaviors(behaviors)
      }
  }
}

extension StyledView where Self: EpoxyableView, Style == Never {
  /// Produces an item to be used within a Group
  /// - Parameters:
  ///   - dataID: the unique identifier for this item
  ///   - content: the content for this item's view
  ///   - behaviors: the behaviors for the view
  /// - Returns: a group item model representing the view
  public static func groupItem(
    dataID: AnyHashable,
    content: Content,
    behaviors: Behaviors? = nil)
  -> GroupItem<Self>
  {
    GroupItem<Self>(
      dataID: dataID,
      content: content,
      make: { Self() },
      setContent: { context, content in
        context.constrainable.setContent(content, animated: context.animated)
      })
      .setBehaviors { context in
        context.constrainable.setBehaviors(behaviors)
      }
  }
}

extension StyledView where Self: EpoxyableView, Content == Never {
  /// Produces an item to be used within a Group
  /// - Parameters:
  ///   - dataID: the unique identifier for this item
  ///   - behaviors: the behaviors for the view
  ///   - style: the style for the view
  /// - Returns: a group item model representing the view
  public static func groupItem(
    dataID: AnyHashable,
    behaviors: Behaviors? = nil,
    style: Style)
  -> GroupItem<Self>
  {
    GroupItem<Self>(
      dataID: dataID,
      make: { Self(style: style) })
      .setBehaviors { context in
        context.constrainable.setBehaviors(behaviors)
      }
  }
}

extension StyledView where Self: EpoxyableView, Content == Never, Style == Never {
  /// Produces an item to be used within a Group
  /// - Parameters:
  ///   - dataID: the unique identifier for this item
  ///   - behaviors: the behaviors for the view
  /// - Returns: a group item model representing the view
  public static func groupItem(
    dataID: AnyHashable,
    behaviors: Behaviors? = nil)
  -> GroupItem<Self>
  {
    GroupItem<Self>(
      dataID: dataID,
      make: { Self() })
      .setBehaviors { context in
        context.constrainable.setBehaviors(behaviors)
      }
  }
}
