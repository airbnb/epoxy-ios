// Created by eric_horacek on 1/7/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - UICollectionViewCompositionalLayout

extension UICollectionViewCompositionalLayout {

  // MARK: Public

  /// Vends a compositional layout that has its section layout determined by invoking the
  /// `layoutSectionProvider` of its `CollectionView`'s corresponding `SectionModel` for each
  /// section.
  public static var epoxy: UICollectionViewCompositionalLayout {
    epoxy(UICollectionViewCompositionalLayout.init(sectionProvider:))
  }

  /// Vends a compositional layout that has its section layout determined by invoking the
  /// `layoutSectionProvider` of its `CollectionView`'s corresponding `SectionModel` for each
  /// section.
  public static func epoxy(
    configuration: UICollectionViewCompositionalLayoutConfiguration)
    -> UICollectionViewCompositionalLayout
  {
    epoxy { provider in
      UICollectionViewCompositionalLayout(sectionProvider: provider, configuration: configuration)
    }
  }

  // MARK: Private

  private typealias MakeLayout = (@escaping UICollectionViewCompositionalLayoutSectionProvider)
    -> UICollectionViewCompositionalLayout

  private static func epoxy(
    _ makeLayout: MakeLayout)
    -> UICollectionViewCompositionalLayout
  {
    weak var layoutReference: UICollectionViewCompositionalLayout?

    let provider: UICollectionViewCompositionalLayoutSectionProvider = { index, environment in
      guard let collectionView = layoutReference?.collectionView as? CollectionView else {
        EpoxyLogger.shared.assertionFailure(
          """
          Epoxy compositional layout does not have a corresponding CollectionView. This is \
          programmer error.
          """)
        return nil
      }

      return collectionView.section(at: index)?.compositionalLayoutSectionProvider?(environment)
    }

    let layout = makeLayout(provider)

    layoutReference = layout

    return layout
  }
}
