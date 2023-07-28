// Created by Sammy Gutiérrez on 7/28/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import EpoxyCore

/// A result builder that enables a DSL for building arrays of supplementary item models.
///
/// For example:
/// ```
/// @SupplementaryItemModelBuilder var items: [SupplementaryItemModeling] {
///    MyView.supplementaryItemModel(…)
///    MyOtherView.supplementaryItemModel(…)
/// }
/// ```
///
/// Will return an array containing two supplementary item models.
public typealias SupplementaryItemModelBuilder = EpoxyModelArrayBuilder<SupplementaryItemModeling>
