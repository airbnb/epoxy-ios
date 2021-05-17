// Created by Tyler Hedrick on 3/25/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import Foundation

/// An internal type to represent items within a group
protocol InternalGroupItemModeling: GroupItemModeling, EpoxyModeled {
  /// The unique identifier for this group item
  var dataID: AnyHashable { get }
  /// create a constrainable that this group item represents
  func makeConstrainable() -> Constrainable
  /// update the constrainable with the current content
  func update(_ constrainable: Constrainable, animated: Bool)
  /// set any behaviors on the constrainable (this is called more frequently than update)
  func setBehaviors(on constrainable: Constrainable)
}
