// Created by eric_horacek on 12/3/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

/// The capability of providing string that identifies a cell for reuse.
public protocol ReuseIDProviding {
  /// The reuseID for the cell that contains the view.
  var reuseID: String { get }
}
