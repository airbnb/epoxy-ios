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

  override func viewDidLoad() {
    super.viewDidLoad()

    // Currently required to get the first layout pass to have the correct cell size.
    DispatchQueue.main.async {
      self.collectionView.collectionViewLayout.invalidateLayout()
    }
  }

  override func epoxySections() -> [EpoxySection] {
    let items = (0..<10)
      .map { dataID -> EpoxyableModel in
        return BaseEpoxyModelBuilder<CustomSizingView, Int>(
          data: dataID,
          dataID: dataID)
          .build()
      }

    return [EpoxySection(items: items)]
  }
}
