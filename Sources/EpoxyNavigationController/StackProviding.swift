// Created by eric_horacek on 3/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - StackProviding

/// The ability to provide a stack of navigation models that drives a stack of view controllers
/// within a declarative navigation controller.
///
/// Generally conformed to by the content of a declarative navigation controller.
public protocol StackProviding {
  /// The stack of navigation models that represent to the view controllers that are present in the
  /// navigation controller's stack.
  var stack: [NavigationModel?] { get }
}
