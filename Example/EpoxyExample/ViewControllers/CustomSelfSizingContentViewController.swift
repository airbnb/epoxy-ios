// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class CustomSelfSizingContentViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setSections(sections, animated: false)
  }

  // MARK: Private

  private var sections: [SectionModel] {
    [
      SectionModel(items: (0..<10).map { (dataID: Int) in
        CustomSizingView.itemModel(dataID: dataID)
      }),
    ]
  }
}
