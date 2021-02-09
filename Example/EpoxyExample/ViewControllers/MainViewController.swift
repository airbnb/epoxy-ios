// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - MainViewController

final class MainViewController: NavigationController {

  // MARK: Lifecycle

  init() {
    super.init(wrapNavigation: NavigationWrapperViewController.init(navigationController:))
    setStack(stack, animated: false)
  }

  // MARK: Internal

  enum Example: CaseIterable {
    case readme
    case product
    case compositionalLayout
    case cardStack
    case flowLayout
    case shuffle
    case customSelfSizing
  }

  // MARK: Private

  private struct State {
    var showExample: Example?
    var showReadmeExample: ReadmeExample?
  }

  private enum DataID: Hashable {
    case index
    case item(Example)
    case readme(ReadmeExample)
  }

  private var state = State() {
    didSet { setStack(stack, animated: true) }
  }

  private var stack: [NavigationModel?] {
    [
      indexModel,
      state.showExample.map(exampleModel(example:)),
      state.showReadmeExample.map(readmeExampleModel(example:)),
    ]
  }

  private var indexModel: NavigationModel {
    .root(dataID: DataID.index) { [weak self] in
      self?.makeExampleIndexViewController()
    }
  }

  private func exampleModel(example: Example) -> NavigationModel {
    NavigationModel(
      dataID: DataID.item(example),
      makeViewController: { [weak self] in
        self?.makeExampleController(example: example)
      },
      remove: { [weak self] in
        self?.state.showExample = nil
      })
  }

  private func readmeExampleModel(example: ReadmeExample) -> NavigationModel {
    NavigationModel(
      dataID: DataID.readme(example),
      makeViewController: {
        example.makeViewController()
      },
      remove: { [weak self] in
        self?.state.showReadmeExample = nil
      })
  }

  private func makeExampleIndexViewController() -> UIViewController {
    let viewController = CollectionViewController(
      layout: UICollectionViewCompositionalLayout.list,
      sections: [
        SectionModel(items: Example.allCases.map { example in
          TextRow.itemModel(
            dataID: example,
            content: .init(title: example.title, body: example.body),
            style: .small)
            .didSelect { [weak self] _ in
              self?.state.showExample = example
            }
        }),
      ])
    viewController.title = "Epoxy"
    return viewController
  }

  private func makeExampleController(example: Example) -> UIViewController {
    let viewController: UIViewController
    switch example {
    case .readme:
      viewController = ReadmeExamplesViewController(didSelect: { [weak self] example in
        self?.state.showReadmeExample = example
      })
    case .compositionalLayout:
      viewController = CompositionalLayoutViewController()
    case .shuffle:
      viewController = ShuffleViewController()
    case .customSelfSizing:
      viewController = CustomSelfSizingContentViewController()
    case .product:
      viewController = ProductViewController()
    case .flowLayout:
      viewController = FlowLayoutViewController()
    case .cardStack:
      viewController = CardStackViewController()
    }
    viewController.title = example.title
    return viewController
  }

}

extension MainViewController.Example {
  var title: String {
    switch self {
    case .readme:
      return "Readme examples"
    case .customSelfSizing:
      return "Custom self-sizing cells"
    case .compositionalLayout:
      return "Compositional Layout"
    case .shuffle:
      return "Shuffle demo"
    case .product:
      return "Product Detail Page"
    case .flowLayout:
      return "Flow Layout demo"
    case .cardStack:
      return "Card Stack"
    }
  }

  var body: String {
    switch self {
    case .readme:
      return "All of the examples from the README"
    case .customSelfSizing:
      return "A CollectionView with custom self-sizing cells"
    case .compositionalLayout:
      return "A CollectionView with a UICollectionViewCompositionalLayout"
    case .shuffle:
      return "A CollectionView with cells that are randomly shuffled on a timer"
    case .product:
      return "An example that combines collections, bars, and presentations"
    case .flowLayout:
      return "A CollectionView with a UICollectionViewFlowLayout"
    case .cardStack:
      return "A CollectionView with BarStackView items that have a card drawn around each stack"
    }
  }
}

// MARK: - NavigationWrapperViewController

/// A naive implementation a Navigation wrapper so we can nest the `FormNavigationController`
/// without a crash.
///
/// You probably want a custom wrapper for your use cases.
final class NavigationWrapperViewController: UIViewController {
  init(navigationController: UINavigationController) {
    // A naive implementation of `wrapNavigation` so we can nest the `FormNavigationController`.
    navigationController.setNavigationBarHidden(true, animated: false)

    super.init(nibName: nil, bundle: nil)

    addChild(navigationController)
    view.addSubview(navigationController.view)
    navigationController.view.frame = view.bounds
    navigationController.view.translatesAutoresizingMaskIntoConstraints = true
    navigationController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    navigationController.didMove(toParent: self)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
