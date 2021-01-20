// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import Epoxy

class CustomSelfSizingContentViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.listNoDividers)
    title = "Custom self-sizing"
  }

  // MARK: CollectionViewController

  override func epoxySections() -> [SectionModel] {
    [
      SectionModel(items: (Int(0)..<Int(10)).map { dataID in
        CustomSizingView.itemModel(dataID: dataID)
      }),
    ]
  }
}
