// Created by eric_horacek on 1/7/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

/// A closure that's invoked with the current layout environment to determine the layout of a
/// section when contained in a `UICollectionViewCompositionalLayout.epoxy` layout.
public typealias CompositionalLayoutSectionProvider = (_ environment: NSCollectionLayoutEnvironment)
  -> NSCollectionLayoutSection

// MARK: - CompositionalLayoutSectionProviderProviding

public protocol CompositionalLayoutSectionProviderProviding {
  /// A closure that's invoked with the current layout environment to determine the layout of a
  /// section when contained in a `UICollectionViewCompositionalLayout.epoxy` layout.
  var compositionalLayoutSectionProvider: CompositionalLayoutSectionProvider? { get }
}

// MARK: - SectionModel

extension SectionModel {

  // MARK: Public

  /// A closure that's invoked with the current layout environment to determine the layout of a
  /// section when contained in a `UICollectionViewCompositionalLayout.epoxy` layout.
  public var compositionalLayoutSectionProvider: CompositionalLayoutSectionProvider? {
    get { self[compositionalLayoutSectionProviderProperty] }
    set { self[compositionalLayoutSectionProviderProperty] = newValue }
  }

  /// Returns a copy of this model with the `compositionalLayoutSectionProvider` replaced with the
  /// provided `value`.
  public func compositionalLayoutSectionProvider(_ value: CompositionalLayoutSectionProvider?) -> Self {
    copy(updating: compositionalLayoutSectionProviderProperty, to: value)
  }

  /// Returns a copy of this model with the `compositionalLayoutSectionProvider` replaced with a
  /// provider that returns the given `section`.
  public func compositionalLayoutSection(_ section: NSCollectionLayoutSection?) -> Self {
    copy(updating: compositionalLayoutSectionProviderProperty, to: section.map { section in
      { _ in section }
    })
  }

  // MARK: Private

  private var compositionalLayoutSectionProviderProperty: EpoxyModelProperty<CompositionalLayoutSectionProvider?> {
    .init(
      keyPath: \CompositionalLayoutSectionProviderProviding.compositionalLayoutSectionProvider,
      defaultValue: nil,
      updateStrategy: .replace)
  }
}
