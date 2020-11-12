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

  override func viewDidLoad() {
    super.viewDidLoad()

    // Currently required to get the first layout pass to have the correct cell size.
    DispatchQueue.main.async {
      self.collectionView.collectionViewLayout.invalidateLayout()
    }
  }

  // MARK: EpoxyCollectionViewController

  override func epoxySections() -> [EpoxySection] {
    let items = (0..<10)
      .map { dataID -> EpoxyableModel in
        let text = kTestTexts[dataID]
        return BaseEpoxyModelBuilder<Row, String>(
          data: text,
          dataID: dataID)
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
          .build()
      }

    return [EpoxySection(items: items)]
  }
}
