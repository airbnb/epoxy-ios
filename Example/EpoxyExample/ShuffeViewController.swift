// Created by Logan Shire on 1/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class ShuffleViewController: EpoxyCollectionViewController {

  // MARK: Properties

  private var timer: Timer?

  // MARK: Initialization

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.example())

    self.tabBarItem = UITabBarItem.init(tabBarSystemItem: .bookmarks, tag: 0)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      guard let self = self else {
        timer.invalidate()
        return
      }

      self.updateData(animated: true)
    }
  }

  // MARK: EpoxyCollectionViewController

  override func epoxySections() -> [SectionModel] {
    let items = (0..<10)
      .shuffled()
      .filter { _ in Int.random(in: 0..<3) % 3 != 0 }
      .map { dataID -> ItemModeling in
        let text = kTestTexts[dataID]
        return ItemModel<Row, String>(
          dataID: dataID,
          content: text)
          .configureView { context in
            context.view.titleText = "Row \(dataID)"
            context.view.text = text
          }
          .didSelect { context in
            print("DataID selected \(context.dataID) (selection handler)")
          }
      }

    return [SectionModel(items: items)]
  }
}
