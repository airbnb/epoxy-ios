// Created by eric_horacek on 3/23/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - PresentationProviding

/// The ability to provide a presentation model that drives the modal presentations and dismissals
/// atop a presenting view controller.
///
/// Generally conformed to by the content of the presenting view controller.
public protocol PresentationProviding {
  /// The presentation model for the view controller that should be presented, else `nil` if nothing
  /// should be presented or if the previous presentation should be dismissed.
  var presentation: PresentationModel? { get }
}
