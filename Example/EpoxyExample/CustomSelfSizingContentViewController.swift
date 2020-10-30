// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import Epoxy

class CustomSelfSizingContentViewController: EpoxyTableViewController {

  override init(epoxyLogger: EpoxyLogging = DefaultEpoxyLogger()) {
    super.init(epoxyLogger: epoxyLogger)
    self.tabBarItem = UITabBarItem.init(tabBarSystemItem: .more, tag: 2)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: EpoxyTableViewController

  override func epoxySections() -> [EpoxySection] {
    let items = (0..<10)
      .map { dataID -> EpoxyableModel in
        return _BaseEpoxyModelBuilder<CustomSizingView, Int, Int>(
          data: dataID,
          dataID: dataID)
          .build()
      }

    return [EpoxySection(items: items)]
  }
}
