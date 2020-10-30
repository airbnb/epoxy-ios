// Created by Logan Shire on 1/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class ShuffleViewController: EpoxyTableViewController {

  // MARK: Properties

  private var timer: Timer?

  // MARK: Initialization

  override init(epoxyLogger: EpoxyLogging = DefaultEpoxyLogger()) {
    super.init(epoxyLogger: epoxyLogger)

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

  // MARK: EpoxyTableViewController

  override func epoxySections() -> [EpoxySection] {
    let items = (0..<10)
      .shuffled()
      .filter { _ in Int.random(in: 0..<3) % 3 != 0 }
      .map { dataID -> EpoxyableModel in
        let text = kTestTexts[dataID]
        return _BaseEpoxyModelBuilder<Row, String, Int>(
          data: text,
          dataID: dataID)
          .configureView { context in
            context.view.titleText = "Row \(dataID)"
            context.view.text = text
          }
          .didSelect { context in
            print("DataID selected \(context.dataID) (selection handler)")
          }
          .build()
      }

    return [EpoxySection(items: items)]
  }
}

