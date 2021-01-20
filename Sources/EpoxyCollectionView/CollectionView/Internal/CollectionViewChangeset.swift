// Created by eric_horacek on 12/14/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - CollectionViewChangeset

/// A set of the minimum changes to get from one array of `SectionModel`s to another, used for
/// diffing.
struct CollectionViewChangeset {
  /// A set of the minimum changes to get from one set of sections to another.
  var sectionChangeset: IndexSetChangeset

  /// A set of the minimum changes to get from one set of items to another, aggregated across all
  /// sections.
  var itemChangeset: IndexPathChangeset

  /// A set of the minimum changes to get from one set of supplementary items to another, aggregated
  /// across all sections, keyed by supplementary element kind.
  var supplementaryItemChangeset: [String: IndexPathChangeset]
}
