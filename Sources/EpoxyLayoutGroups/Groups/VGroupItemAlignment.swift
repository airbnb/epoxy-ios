// Created by Tyler Hedrick on 5/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

extension VGroup {
  /// Horizontal alignment options to use within `VGroup`
  public enum ItemAlignment: Hashable, Equatable {

    /// Align leading and trailing edges of the item tightly to the leading and trailing edges of the group.
    /// Components shorter than the group's width will be stretched to the width of the group
    case fill

    /// Align the leading edge of an item to the leading edge of the group.
    /// Components shorter than the group's width will not be stretched
    case leading

    /// Align the trailing edge of an item to the trailing edge of the group.
    /// Components shorter than the group's width will not be stretched
    case trailing

    /// Align the center of the item to the center of the group horizontally.
    /// Components shorter than the group's width will not be stretched
    case center

    /// Horizontally center one item to another. The other item does not need to be in
    /// the same group, but it must share a common ancestor with the item it is centered to.
    /// Components shorter than the group's width will not be stretched
    case centered(to: Constrainable)

    /// Provide a block that returns a set of custom constraints.
    ///
    /// - Parameter alignmentID: a hashable identifier to uniquely identify this custom layout prvodier
    /// - Parameter layoutProvider: a closure used to build a custom layout given a container and a constrainable
    ///     container: the parent container that should be constrained to
    ///     constrainable: the constrainable that this alignment is affecting
    case custom(
      alignmentID: AnyHashable,
      layoutProvider: (_ container: Constrainable, _ constrainable: Constrainable) -> [NSLayoutConstraint])

    // MARK: Public

    // MARK: Equatable

    public static func ==(lhs: ItemAlignment, rhs: ItemAlignment)
      -> Bool
    {
      switch (lhs, rhs) {
      case (.fill, .fill),
           (.leading, .leading),
           (.center, .center),
           (.trailing, .trailing):
        return true
      case let (.centered(c1), .centered(c2)):
        return c1.isEqual(to: c2)
      case (.custom(let id1, _), .custom(let id2, _)):
        return id1 == id2
      default:
        return false
      }
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
      switch self {
      case .fill:
        hasher.combine(HashableAlignment.fill)
      case .leading:
        hasher.combine(HashableAlignment.leading)
      case .trailing:
        hasher.combine(HashableAlignment.trailing)
      case .center:
        hasher.combine(HashableAlignment.center)
      case .centered(to: let to):
        hasher.combine(to.dataID)
      case .custom(let alignmentID, _):
        hasher.combine(alignmentID)
      }
    }

    // MARK: Private

    private enum HashableAlignment {
      case fill, leading, trailing, center
    }
  }
}
