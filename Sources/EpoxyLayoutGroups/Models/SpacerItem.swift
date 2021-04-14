// Created by Tyler Hedrick on 3/19/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

/// A `GroupItemModeling` implementation of `Spacer` to be used within groups
public struct SpacerItem {

  public init(
    dataID: AnyHashable,
    style: Spacer.Style = .init()) 
  {
    self.dataID = dataID
    self.style = style
  }

  // MARK: Private

  public var dataID: AnyHashable
  public var style: Spacer.Style
}

extension SpacerItem: GroupItemModeling {
  public func eraseToAnyGroupItem() -> AnyGroupItem {
    GroupItem<Spacer>(dataID: dataID) {
      Spacer(style: style)
    }
    .eraseToAnyGroupItem()
  }

  public var diffIdentifier: AnyHashable {
    DiffIdentifier(dataID: dataID, style: style)
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? SpacerItem else {
      return false
    }
    return dataID == other.dataID && style == other.style
  }
}

// MARK: DiffIdentifier

private struct DiffIdentifier: Hashable {
  let dataID: AnyHashable
  let style: Spacer.Style
}