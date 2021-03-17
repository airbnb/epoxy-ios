// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class MainViewController: NavigationController {

  // MARK: Lifecycle

  init() {
    super.init(wrapNavigation: NavigationWrapperViewController.init(navigationController:))
    setStack(stack, animated: false)
  }

  // MARK: Private

  private enum DataID: Hashable {
    case index
    case item(Example)
    case readme(ReadmeExample)
  }

  private struct State {
    var showExample: Example?
    var showReadmeExample: ReadmeExample?
  }

  private var state = State() {
    didSet { setStack(stack, animated: true) }
  }

  @NavigationModelBuilder private var stack: [NavigationModel] {
    NavigationModel.root(dataID: DataID.index) { [weak self] in
      self?.makeExampleIndexViewController()
    }

    if let example = state.showExample {
      NavigationModel(
        dataID: DataID.item(example),
        makeViewController: { [weak self] in
          self?.makeExampleController(example)
        },
        remove: { [weak self] in
          self?.state.showExample = nil
        })
    }

    if let example = state.showReadmeExample {
      NavigationModel(
        dataID: DataID.readme(example),
        makeViewController: { [weak self] in
          self?.makeReadmeExampleViewController(example)
        },
        remove: { [weak self] in
          self?.state.showReadmeExample = nil
        })
    }
  }

  private func makeExampleIndexViewController() -> UIViewController {
    let viewController = CollectionViewController(
      layout: UICollectionViewCompositionalLayout.list,
      items: {
        Example.allCases.map { example in
          TextRow.itemModel(
            dataID: example,
            content: .init(title: example.title, body: example.body),
            style: .small)
            .didSelect { [weak self] _ in
              self?.state.showExample = example
            }
        }
      })
    viewController.title = "Epoxy"
    return viewController
  }

  private func makeExampleController(_ example: Example) -> UIViewController {
    let viewController: UIViewController
    switch example {
    case .readme:
      viewController = CollectionViewController.readmeExamplesViewController(
        didSelect: { [weak self] example in
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

  private func makeReadmeExampleViewController(_ example: ReadmeExample) -> UIViewController {
    switch example {
    case .tapMe:
      return CollectionViewController.makeTapMeViewController()
    case .counter:
      return CounterViewController()
    case .bottomButton:
      return BottomButtonViewController()
    case .formNavigation:
      return FormNavigationController()
    case .modalPresentation:
      return PresentationViewController()
    }
  }

}
