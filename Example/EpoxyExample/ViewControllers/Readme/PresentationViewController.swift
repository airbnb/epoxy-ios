// Created by eric_horacek on 1/29/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - PresentationViewController

/// Source code for `EpoxyPresentations` example from `README.md`:
final class PresentationViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setPresentation(presentation, animated: true)
  }

  // MARK: Private

  private enum DataID {
    case detail
  }

  private var showDetail = true {
    didSet { setPresentation(presentation, animated: true) }
  }

  private var presentation: PresentationModel? {
    guard showDetail else { return nil }

    return PresentationModel(
      dataID: DataID.detail,
      presentation: .system,
      makeViewController: { [weak self] in
        DetailViewController(didTapDismiss: {
          self?.showDetail = false
        })
      },
      dismiss: { [weak self] in
        self?.showDetail = false
      })
  }

}

// MARK: - DetailViewController

final class DetailViewController: CollectionViewController {

  // MARK: Lifecycle

  init(didTapDismiss: @escaping () -> Void) {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    topBarInstaller.setBars([
      ButtonRow.barModel(content: .init(text: "Dismiss"), behaviors: .init(didTap: didTapDismiss)),
    ], animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    topBarInstaller.install()
  }

  // MARK: Private

  private lazy var topBarInstaller = TopBarInstaller(viewController: self)
}
