// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import Epoxy

class CustomSelfSizingContentViewController: EpoxyCollectionViewController {

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.example())
    title = "Custom self-sizing"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: EpoxyCollectionViewController

  override func epoxySections() -> [SectionModel] {
    [
      SectionModel(
        items: (0..<10).map { dataID in
          ItemModel<CustomSizingView, Int>(dataID: dataID, content: dataID)
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
