// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// A view that responds to being selected within a `CollectionView`.
public protocol SelectableView: UIView {
  /// Implement this method on your view to react to selection events from user interaction. Do NOT
  /// use this method to manage internal state for your view.
  /// 
  /// Example use case: override to fire haptics when a user taps the view
  func didSelect()
}
