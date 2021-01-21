// Created by Tyler Hedrick on 1/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class FlowLayoutViewController: CollectionViewController {

  init() {
    super.init(layout: UICollectionViewFlowLayout())
    setSections(sections, animated: false)
  }

  // MARK: Private

  private enum DataIDs {
    enum Sections {
      case section1
      case section2
      case section3
    }

    enum Section1 {
      case red1
      case red2
    }

    enum Section2 {
      case orange
    }

    enum Section3 {
      case header
      case item
      case footer
    }
  }

  private var sections: [SectionModel] {
    [
      // example of setting insets, item spacing, and line spacing for the section
      SectionModel(dataID: DataIDs.Sections.section1, items: firstSection)
        .flowLayoutSectionInset(.init(top: 12, left: 20, bottom: 12, right: 48))
        .flowLayoutMinimumInteritemSpacing(18)
        .flowLayoutMinimumLineSpacing(48),
      // example of setting an item size for the entire section
      SectionModel(dataID: DataIDs.Sections.section2, items: secondSection)
        .flowLayoutItemSize(.init(width: 300, height: 150))
        .flowLayoutSectionInset(.init(top: 0, left: 0, bottom: 0, right: 0)),
      SectionModel(dataID: DataIDs.Sections.section3, items: thirdSection)
        .supplementaryItems(thirdSectionSupplementaryItems)
        // Width is ignored for headers / footers
        .flowLayoutHeaderReferenceSize(.init(width: 0, height: 30))
        .flowLayoutFooterReferenceSize(.init(width: 0, height: 60))
    ]
  }

  private var firstSection: [ItemModeling] {
    [
      ColorView.itemModel(
        dataID: DataIDs.Section1.red1,
        style: .red)
        .flowLayoutItemSize(.init(width: 100, height: 100)),
      ColorView.itemModel(
        dataID: DataIDs.Section1.red2,
        style: .red)
        .flowLayoutItemSize(.init(width: 100, height: 100))
    ]
  }

  private var secondSection: [ItemModeling] {
    [
      ColorView.itemModel(
        dataID: DataIDs.Section2.orange,
        style: .orange)
    ]
  }

  private var thirdSection: [ItemModeling] {
    [
      ColorView.itemModel(
        dataID: DataIDs.Section3.item,
        style: .green)
        .flowLayoutItemSize(.init(width: 200, height: 50))
    ]
  }

  private var thirdSectionSupplementaryItems: [String: [SupplementaryItemModeling]] {
    [
      UICollectionView.elementKindSectionHeader: [
        ColorView.supplementaryItemModel(
          dataID: DataIDs.Section3.header,
          style: .yellow)
      ],
      UICollectionView.elementKindSectionFooter: [
        ColorView.supplementaryItemModel(
          dataID: DataIDs.Section3.footer,
          style: .blue)
      ]
    ]
  }

}
