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
    let items = (0..<10)
      .map { dataID -> ItemModeling in
        let text = kTestTexts[dataID]
        return ItemModel<Row, String>(dataID: dataID, content: text)
          .configureView { context in
            print("First configuration")
            context.view.titleText = "Row \(dataID)"
            context.view.text = text
            context.view.textColor = .red
          }
          .configureView{ context in
            print("Second configuration")
            context.view.textColor = .black
          }
          .didSelect { context in
            print("DataID selected \(context.dataID) (selection handler)")
          }
      }

    return [SectionModel(items: items)]
  }
}
