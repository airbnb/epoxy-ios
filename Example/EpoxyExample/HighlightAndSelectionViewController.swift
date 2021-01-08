// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class HighlightAndSelectionViewController: EpoxyCollectionViewController {
  // MARK: Initialization

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.epoxy)

    self.tabBarItem = UITabBarItem.init(tabBarSystemItem: .history, tag: 1)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: EpoxyCollectionViewController

  enum SectionID {
    case carousel, list
  }

  override func epoxySections() -> [SectionModel] {
    [
      SectionModel(
        dataID: SectionID.carousel,
        items: (0..<10).map { (dataID: Int) in
          ItemModel<Row, RowContent>(
            dataID: dataID,
            content: RowContent(title: nil, subtitle: "Page \(dataID)"))
            .configureView { context in
              print("Carousel page \(dataID) configuration")
              context.view.titleText = context.content.title
              context.view.text = context.content.subtitle
            }
            .didSelect { _ in
              print("Carousel page \(dataID) did select")
            }
            .willDisplay { _ in
              print("Carousel page \(dataID) will display")
            }
        })
        .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [
          SupplementaryItemModel<Row, String>(dataID: 0, content: "Carousel section")
            .configureView { context in
              context.view.titleText = context.content
            }
        ])
        .compositionalLayoutSection(.carousel),
      SectionModel(
        dataID: SectionID.list,
        items: (0..<10).map { dataID in
          ItemModel<Row, RowContent>(
            dataID: dataID,
            content: .init(title: "Row \(dataID)", subtitle: kTestTexts[dataID]))
            .configureView { context in
              print("List row \(dataID) configuration")
              context.view.titleText = context.content.title
              context.view.text = context.content.subtitle
            }
            .didSelect { _ in
              print("List row \(dataID) selected")
            }
            .willDisplay { _ in
              print("List row \(dataID) will display")
            }
        })
        .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [
          SupplementaryItemModel<Row, String>(dataID: 0, content: "List section")
            .configureView { context in
              context.view.titleText = context.content
            }
        ])
        .compositionalLayoutSectionProvider(NSCollectionLayoutSection.list(layoutEnvironment:)),
    ]
  }
}

// MARK: - NSCollectionLayoutSection

extension NSCollectionLayoutSection {
  fileprivate static var carousel: NSCollectionLayoutSection {
    let item = NSCollectionLayoutItem(
      layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(50)))

    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(50)),
      subitems: [item])
    group.contentInsets = .zero

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging

    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)

    section.boundarySupplementaryItems = [sectionHeader]

    return section
  }

  fileprivate static func list(
    layoutEnvironment: NSCollectionLayoutEnvironment)
    -> NSCollectionLayoutSection
  {
    let section: NSCollectionLayoutSection
    if #available(iOS 14, *) {
      section = .list(using: .init(appearance: .plain), layoutEnvironment: layoutEnvironment)
    } else {
      let item = NSCollectionLayoutItem(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)))

      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)),
        subitems: [item])

      section = NSCollectionLayoutSection(group: group)
    }

    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)

    section.boundarySupplementaryItems = [sectionHeader]

    return section
  }
}
