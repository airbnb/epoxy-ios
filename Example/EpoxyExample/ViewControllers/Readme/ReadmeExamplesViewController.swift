// Created by eric_horacek on 1/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - ReadmeExample

enum ReadmeExample: CaseIterable {
  case tapMe, counter, bottomButton, formNavigation

  // MARK: Internal

  var title: String {
    switch self {
    case .tapMe:
      return "Tap Me"
    case .counter:
      return "Counter"
    case .bottomButton:
      return "Bottom button"
    case .formNavigation:
      return "Form Navigation"
    }
  }

  var body: String {
    switch self {
    case .tapMe, .counter:
      return "EpoxyCollectionView"
    case .bottomButton:
      return "EpoxyBars"
    case .formNavigation:
      return "EpoxyNavigationController"
    }
  }

  func makeViewController() -> UIViewController {
    switch self {
    case .tapMe:
      return makeTapMeViewController()
    case .counter:
      return CounterViewController()
    case .bottomButton:
      return BottomButtonViewController()
    case .formNavigation:
      return FormNavigationController()
    }
  }

  // MARK: Private

  /// Source code for `EpoxyCollectionView` "Tap me" example from `README.md`:
  private func makeTapMeViewController() -> UIViewController {
    enum DataID {
      case row
    }

    return CollectionViewController(
      layout: UICollectionViewCompositionalLayout.list,
      sections: [
        SectionModel(items: [
          TextRow.itemModel(
            dataID: DataID.row,
            content: .init(title: "Tap me!"),
            style: .small)
            .didSelect { _ in
              // Handle selection
            },
        ]),
      ])
  }
}

// MARK: - ReadmeExamplesViewController

final class ReadmeExamplesViewController: CollectionViewController {
  init(didSelect: @escaping (ReadmeExample) -> Void) {
    super.init(layout: UICollectionViewCompositionalLayout.list, sections: [
      SectionModel(items: ReadmeExample.allCases.map { example in
        TextRow.itemModel(
          dataID: example,
          content: .init(title: example.title, body: example.body),
          style: .small)
          .didSelect { _ in
            didSelect(example)
          }
      }),
    ])
  }
}
