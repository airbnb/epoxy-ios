// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import Epoxy

class CustomSelfSizingContentViewController: EpoxyCollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.listNoDividers)
    title = "Custom self-sizing"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: EpoxyCollectionViewController

  override func epoxySections() -> [SectionModel] {
    [
      SectionModel(items: (Int(0)..<Int(10)).map { dataID in
        CustomSizingView.itemModel(dataID: dataID)
      }),
    ]
  }
}
