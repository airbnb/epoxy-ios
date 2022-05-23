// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class ProductViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setItems(items, animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.install()
  }

  // MARK: Private

  private enum DataID {
    enum Item {
      case headerImage, titleRow, imageRow
    }

    enum Presentation {
      case buy
    }
  }

    private lazy var bottomBarInstaller: BottomBarInstaller = {
        let anyBars = self.bars
            .map { barModel -> AnyBarModel in
                var erasedBar = barModel.eraseToAnyBarModel()
                erasedBar = erasedBar.willDisplay {
                    print("test")
                }
                
                return erasedBar
            }
        return BottomBarInstaller(viewController: self, bars: anyBars)
    }()

  private var showBuy = false {
    didSet { setPresentation(presentation, animated: true) }
  }

  @ItemModelBuilder private var items: [ItemModeling] {
    ImageMarquee.itemModel(
      dataID: DataID.Item.headerImage,
      // swiftlint:disable:next force_unwrapping
      content: .init(imageURL: URL(string: "https://picsum.photos/id/350/500/500")!),
      style: .init(height: 250, contentMode: .scaleAspectFill))
    TextRow.itemModel(
      dataID: DataID.Item.titleRow,
      content: .init(title: "Our Great Product"),
      style: .large)
    ImageRow.itemModel(
      dataID: DataID.Item.imageRow,
      content: .init(
        title: "Here is our exciting product",
        subtitle: "We think you should buy it.",
        // swiftlint:disable:next force_unwrapping
        imageURL: URL(string: "https://picsum.photos/id/350/500/500")!))
  }

  @BarModelBuilder private var bars: [BarModeling] {
    ButtonRow.barModel(content: .init(text: "Buy now"), behaviors: .init(didTap: { [weak self] in
      self?.showBuy = true
    }))
    .willDisplay { _ in
        print("test")
    }
  }

  @PresentationModelBuilder private var presentation: PresentationModel? {
    if showBuy {
      PresentationModel(
        dataID: DataID.Presentation.buy,
        presentation: .system,
        makeViewController: {
          enum DataID {
            case titleRow
          }

          return CollectionViewController(
            layout: UICollectionViewCompositionalLayout.listNoDividers,
            items: {
              TextRow.itemModel(
                dataID: DataID.titleRow,
                content: .init(
                  title: "You bought it, congrats!",
                  body: "Let's check out"),
                style: .large)
            })
        },
        dismiss: { [weak self] in
          self?.showBuy = false
        })
    }
  }

}
