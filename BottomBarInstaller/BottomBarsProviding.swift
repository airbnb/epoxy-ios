// Created by eric_horacek on 3/23/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - BottomBarsProviding

/// The ability to provide models representing a stack of bar views at the bottom of a screen.
///
/// Generally conformed to by view controller content.
public protocol BottomBarsProviding {
  /// The stack of bars displayed at the bottom of the screen ordered from top to bottom, else an
  /// empty array if there should be none.
  ///
  /// - SeeAlso: BarModel
  var bottomBars: [BarModeling] { get }
}
