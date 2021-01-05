// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class HighlightAndSelectionViewController: EpoxyCollectionViewController {
  // MARK: Initialization

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.example())

    self.tabBarItem = UITabBarItem.init(tabBarSystemItem: .history, tag: 1)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: EpoxyCollectionViewController

  override func epoxySections() -> [SectionModel] {
    [
      SectionModel(
        items: (0..<10).map { dataID -> ItemModeling in
          ItemModel<Row, RowContent>(
            dataID: dataID,
            content: .init(
              title: "Row \(dataID)",
              subtitle: kTestTexts[dataID]))
            .configureView { context in
              print("First configuration")
              context.view.titleText = context.content.title
              context.view.text = context.content.subtitle
              context.view.textColor = .red
            }
            .configureView { context in
              print("Second configuration")
              context.view.textColor = .black
            }
            .didSelect { context in
              print("DataID selected \(context.dataID) (selection handler)")
            }
        })
        .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [
          SupplementaryItemModel<Row, String>(dataID: 0, content: "Section 0")
            .configureView { context in
              context.view.titleText = context.content
            }
        ])
    ]
  }
}
