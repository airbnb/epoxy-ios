// Created by Tyler Hedrick on 1/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class FlowLayoutViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewFlowLayout())
    setSections(sections, animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.alwaysBounceVertical = true
  }

  // MARK: Private

  private enum DataID {
    enum Section {
      case red, orange, blue
    }

    enum Red {
      case red1, red2
    }

    enum Orange {
      case orange1
    }

    enum Blue {
      case header, item, footer
    }
  }

  private var sections: [SectionModel] {
    [redSection, orangeSection, blueSection]
  }

  private var redSection: SectionModel {
    // Example of setting insets, item spacing, and line spacing for the section
    SectionModel(
      dataID: DataID.Section.red,
      items: [
        ColorView.itemModel(
          dataID: DataID.Red.red1,
          style: .red)
          .flowLayoutItemSize(.init(width: 100, height: 100)),
        ColorView.itemModel(
          dataID: DataID.Red.red2,
          style: .red)
          .flowLayoutItemSize(.init(width: 100, height: 100)),
      ])
      .flowLayoutSectionInset(.init(top: 12, left: 20, bottom: 12, right: 48))
      .flowLayoutMinimumInteritemSpacing(18)
      .flowLayoutMinimumLineSpacing(48)
  }

  private var orangeSection: SectionModel {
    // Example of setting an item size for the entire section
    SectionModel(
      dataID: DataID.Section.orange,
      items: [
        ColorView.itemModel(
          dataID: DataID.Orange.orange1,
          style: .orange),
      ])
      .flowLayoutItemSize(.init(width: 300, height: 150))
      .flowLayoutSectionInset(.init(top: 0, left: 0, bottom: 0, right: 0))
  }

  private var blueSection: SectionModel {
    // Example of setting an item size for the entire section
    SectionModel(
      dataID: DataID.Section.blue,
      items: [
        ColorView.itemModel(
          dataID: DataID.Blue.item,
          style: .green)
          .flowLayoutItemSize(.init(width: 200, height: 50)),
      ])
      .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [
        ColorView.supplementaryItemModel(
          dataID: DataID.Blue.header,
          style: .yellow),
      ])
      // Width is ignored for headers
      .flowLayoutHeaderReferenceSize(.init(width: 0, height: 30))
      .supplementaryItems(ofKind: UICollectionView.elementKindSectionFooter, [
        ColorView.supplementaryItemModel(
          dataID: DataID.Blue.footer,
          style: .blue),
      ])
      // Width is ignored for footers
      .flowLayoutFooterReferenceSize(.init(width: 0, height: 60))
  }

}
