// Created by eric_horacek on 3/23/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - TopBarsProviding

/// The ability to provide models representing a stack of bar views at the top of a screen.
///
/// Generally conformed to by view controller content.
public protocol TopBarsProviding {
  /// The stack of bars displayed at the top of the screen ordered from top to bottom, else an empty
  /// array if there should be none.
  ///
  /// - SeeAlso: BasicNavigationBarModel
  /// - SeeAlso: OverlayNavigationBarModel
  /// - SeeAlso: BarModel
  /// - SeeAlso: TopBarInstaller
  var topBars: [BarModeling] { get }
}
