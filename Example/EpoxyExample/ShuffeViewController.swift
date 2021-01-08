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
    [
      SectionModel(
        items: (0..<10).shuffled().filter { _ in Int.random(in: 0..<3) % 3 != 0 }.map { dataID in
          ItemModel<Row, RowContent>(
            dataID: dataID,
            content: .init(
              title: "Row \(dataID)",
              subtitle: kTestTexts[dataID]))
            .configureView { context in
              context.view.titleText = context.content.title
              context.view.text = context.content.subtitle
            }
            .didSelect { context in
              print("Shuffle selected \(context.dataID) (selection handler)")
            }
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
