// Created by eric_horacek on 1/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

/// Source code for `EpoxyBars` "Bottom Button" example from `README.md`:
class BottomButtonViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    bottomBarInstaller.install()
  }

  // MARK: Private

  private lazy var bottomBarInstaller = BottomBarInstaller(
    viewController: self,
    bars: bars)

  @BarModelBuilder private var bars: [BarModeling] {
    ButtonRow.barModel(
      content: .init(text: "Click me!"),
      behaviors: .init(didTap: {
        // Handle button selection
      }))
  }
}
