// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import Epoxy

class CustomSelfSizingContentViewController: EpoxyCollectionViewController {

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.example())
    self.tabBarItem = UITabBarItem.init(tabBarSystemItem: .more, tag: 2)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: EpoxyCollectionViewController

  override func epoxySections() -> [SectionModel] {
    let items = (0..<10).map { dataID in
      ItemModel<CustomSizingView, Int>(dataID: dataID, content: dataID)
    }

    return [SectionModel(items: items)]
  }
}
