// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class HighlightAndSelectionViewController: EpoxyCollectionViewController {

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.epoxy)
    title = "Highlight and Selection"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  enum SectionID {
    case carousel, list
  }

  override func epoxySections() -> [SectionModel] {
    [
      SectionModel(
        dataID: SectionID.carousel,
        items: (0..<10).map { (dataID: Int) in
          Row.itemModel(
            dataID: dataID,
            content: .init(title: "Page \(dataID)"),
            style: .small)
            .didSelect { _ in
              print("Carousel page \(dataID) did select")
            }
            .willDisplay { _ in
              print("Carousel page \(dataID) will display")
            }
        })
        .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [
          Row.supplementaryItemModel(dataID: 0, content: .init(title: "Carousel section"), style: .large)
        ])
        .compositionalLayoutSection(.carouselWithHeader),
      SectionModel(
        dataID: SectionID.list,
        items: (0..<10).map { (dataID: Int) in
          Row.itemModel(
            dataID: dataID,
            content: .init(title: "Row \(dataID)", body: BeloIpsum.paragraph(count: 1, seed: dataID)),
            style: .small)
            .didSelect { _ in
              print("List row \(dataID) selected")
            }
            .willDisplay { _ in
              print("List row \(dataID) will display")
            }
        })
        .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [
          Row.supplementaryItemModel(dataID: 0, content: .init(title: "List section"), style: .large)
        ])
        .compositionalLayoutSectionProvider(NSCollectionLayoutSection.listWithHeader),
    ]
  }

}
