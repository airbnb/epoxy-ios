// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

public protocol Highlightable {
  /// Implement this method on your view to react to highlight events
  /// Do NOT use this method to manage internal state for your view
  /// Example use case: override to animate a shrink / grow effect
  /// when the user highlights a cell
  func didHighlight(_ highlighted: Bool)
}
