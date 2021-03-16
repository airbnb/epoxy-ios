// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

/// A result builder that enables a DSL for building arrays of item models.
///
/// For example:
/// ```
/// @ItemModelBuilder var items: [ItemModeling] {
///    MyView.itemModel(…)
///    MyOtherView.itemModel(…)
/// }
/// ```
///
/// Will return an array containing two item models.
public typealias ItemModelBuilder = EpoxyModelArrayBuilder<ItemModeling>
