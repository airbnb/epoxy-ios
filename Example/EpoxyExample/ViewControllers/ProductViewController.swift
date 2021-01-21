// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class ProductViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setSections(sections, animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.install()
  }

  // MARK: Private

  private enum DataID {
    case headerImage
    case titleRow
    case imageRow
  }

  private lazy var bottomBarInstaller = BottomBarInstaller(viewController: self, bars: bars)

  private var sections: [SectionModel] {
    [
      SectionModel(items: [
        ImageMarquee.itemModel(
          dataID: DataID.headerImage,
          content: .init(imageURL: URL(string: "https://picsum.photos/id/350/500/500")!),
          style: .init(height: 250, contentMode: .scaleAspectFill)),
        TextRow.itemModel(
          dataID: DataID.titleRow,
          content: .init(title: "Our Great Product"),
          style: .large),
        ImageRow.itemModel(
          dataID: DataID.imageRow,
          content: .init(
            title: "Here is our exciting product",
            subtitle: "We think you should buy it.",
            imageURL: URL(string: "https://picsum.photos/id/350/500/500")!)),
      ]),
    ]
  }

  private var bars: [BarModeling] {
    [
      ButtonRow.barModel(content: .init(text: "Buy now")),
    ]
  }

}
