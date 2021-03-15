// Created by eric_horacek on 1/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - FormNavigationController

/// Source code for `EpoxyNavigationController` "Form Navigation" example from `README.md`:
final class FormNavigationController: NavigationController {

  // MARK: Lifecycle

  init() {
    super.init()
    setStack(stack, animated: false)
  }

  // MARK: Private

  private struct State {
    var showStep2 = false
  }

  private enum DataID {
    case step1, step2
  }

  private var state = State() {
    didSet { setStack(stack, animated: true) }
  }

  @NavigationModelBuilder private var stack: [NavigationModel] {
    NavigationModel.root(dataID: DataID.step1) { [weak self] in
      Step1ViewController(didTapNext: {
        self?.state.showStep2 = true
      })
    }

    if state.showStep2 {
      NavigationModel(
        dataID: DataID.step2,
        makeViewController: {
          Step2ViewController(didTapNext: {
            // Navigate away from this step.
          })
        },
        remove: { [weak self] in
          self?.state.showStep2 = false
        })
    }
  }
}

// MARK: - Step1ViewController

final class Step1ViewController: CollectionViewController {

  // MARK: Lifecycle

  init(didTapNext: @escaping () -> Void) {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    title = "Step 1"
    bottomBarInstaller.setBars([
      ButtonRow.barModel(content: .init(text: "Show step 2"), behaviors: .init(didTap: didTapNext)),
    ], animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.install()
  }

  // MARK: Private

  private lazy var bottomBarInstaller = BottomBarInstaller(viewController: self)
}

// MARK: - Step2ViewController

final class Step2ViewController: CollectionViewController {

  // MARK: Lifecycle

  init(didTapNext: @escaping () -> Void) {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    title = "Step 2"
    bottomBarInstaller.setBars([
      ButtonRow.barModel(content: .init(text: "Finish"), behaviors: .init(didTap: didTapNext)),
    ], animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.install()
  }

  // MARK: Private

  private lazy var bottomBarInstaller = BottomBarInstaller(viewController: self)
}
