// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class ProductViewController: EpoxyCollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.listNoDividers)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    barInstaller.setBars(bars, animated: false)
    barInstaller.install()
  }

  override func epoxySections() -> [SectionModel] {
    [
      SectionModel(items: items)
    ]
  }

  // MARK: Private

  private enum DataID {
    case headerImage
    case titleRow
    case imageRow
  }

  private lazy var barInstaller = BottomBarInstaller(viewController: self)

  private var items: [ItemModeling] {
    [
      ItemModel<UIImageView, URL>(
        dataID: DataID.headerImage,
        content: URL(string: "https://picsum.photos/id/350/500/500")!,
        configureView: { context in
          context.view.contentMode = .scaleAspectFill
          context.view.clipsToBounds = true
          context.view.translatesAutoresizingMaskIntoConstraints = false
          let constraint = context.view.heightAnchor.constraint(equalToConstant: 250)
          constraint.priority = .defaultHigh
          constraint.isActive = true
          context.view.setURL(context.content)
        }),
      Row.itemModel(
        dataID: DataID.titleRow,
        content: .init(title: "Our Great Product"),
        style: .small),
      ImageRow.itemModel(
        dataID: DataID.imageRow,
        content: .init(
          title: "Here is our exciting product",
          subtitle: "We think you should buy it.",
          imageURL: URL(string: "https://picsum.photos/id/350/500/500")!)),
    ]
  }

  private var bars: [BarModeling] {
    [
      ButtonRow.barModel(content: .init(text: "Buy now")),
    ]
  }

}
