// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

/// A result builder that enables a DSL for building arrays of navigation models.
///
/// For example:
/// ```
/// @NavigationModelBuilder var stack: [NavigationModel] {
///   NavigationModel.root(…)
///
///   if showStep1 {
///     NavigationModel(…)
///   }
///
///   if showStep2 {
///     NavigationModel(…)
///   }
/// }
/// ```
///
/// Will return an array of containing three navigation models when both `showStep1` and `showStep2`
/// are `true`
public typealias NavigationModelBuilder = EpoxyModelArrayBuilder<NavigationModel>
