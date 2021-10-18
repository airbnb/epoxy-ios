// Created by oleksandr_zarochintsev on 4/26/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class TextFieldViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setItems([textFieldRowItem], animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.install()
  }

  // MARK: Private

  private enum DataID {
    case username
    case button
  }

  private lazy var bottomBarInstaller = BottomBarInstaller(
    viewController: self,
    avoidsKeyboard: true,
    bars: [buttonRowBar])

  private var username = "@airbnb" {
    didSet { setItems([textFieldRowItem], animated: true) }
  }

  private var textFieldRowItem: ItemModeling {
    TextFieldRow.itemModel(
      dataID: DataID.username,
      content: .init(text: username, placeholder: "Username"),
      behaviors: .init(didUpdateText: { [weak self] username in
        self?.username = username ?? ""
      }),
      style: .base)
  }

  private var buttonRowBar: BarModeling {
    ButtonRow.barModel(
      dataID: DataID.button,
      content: .init(text: "Submit"),
      behaviors: .init(didTap: { [weak self] in
        guard let self = self else { return }
        self.view.endEditing(true)
        print("Submitted '\(self.username)'")
      }))
  }
}
