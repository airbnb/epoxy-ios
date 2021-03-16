// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

/// A result builder that enables a DSL for building arrays of section models.
///
/// For example:
/// ```
/// @SectionModelBuilder var sections: [SectionModel] {
///    SectionModel(…) { … }
///    SectionModel(…) { … }
/// }
/// ```
///
/// Will return an array containing two section models.
public typealias SectionModelBuilder = EpoxyModelArrayBuilder<SectionModel>
