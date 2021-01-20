// Created by Tyler Hedrick on 12/5/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// A view that responds to being displayed within a `CollectionView`.
public protocol DisplayRespondingView: UIView {
  /// Implement this method on your view to react to display events, not to manage internal state
  /// for your view.
  ///
  /// Example use case: override to start / stop animations when the view is displayed / ends
  /// displaying respectively.
  func didDisplay(_ isDisplayed: Bool)
}
