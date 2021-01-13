// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyNavigationController
import Foundation
import UIKit

final class MainViewController: NavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setStack(stack, animated: false)
  }

  // MARK: Private

  private struct State {
    var showCustomSelfSizing = false
    var showHighlightAndSelection = false
    var showShuffle = false
  }

  private enum DataIDs {
    case index
    case customSelfSizing
    case higlightAndSelection
    case shuffle
  }

  private var state = State() {
    didSet {
      setStack(stack, animated: true)
    }
  }

  private var stack: [NavigationModel?] {
    [
      root,
      customSelfSizing,
      highlightAndSelection,
      shuffle
    ]
  }

  private var root: NavigationModel {
    .root(dataID: DataIDs.index) { [weak self] in
      IndexViewController { item in
        switch item {
        case .customSelfSizing:
          self?.state.showCustomSelfSizing = true
        case .highlightAndSelection:
          self?.state.showHighlightAndSelection = true
        case .shuffle:
          self?.state.showShuffle = true
        }
      }
    }
  }

  private var customSelfSizing: NavigationModel? {
    guard state.showCustomSelfSizing else { return nil }
    return NavigationModel(
      dataID: DataIDs.customSelfSizing,
      makeViewController: {
        CustomSelfSizingContentViewController()
      },
      remove: { [weak self] in
        self?.state.showCustomSelfSizing = false
      })
  }

  private var highlightAndSelection: NavigationModel? {
    guard state.showHighlightAndSelection else { return nil }
    return NavigationModel(
      dataID: DataIDs.customSelfSizing,
      makeViewController: {
        HighlightAndSelectionViewController()
      },
      remove: { [weak self] in
        self?.state.showHighlightAndSelection = false
      })
  }

  private var shuffle: NavigationModel? {
    guard state.showShuffle else { return nil }
    return NavigationModel(
      dataID: DataIDs.customSelfSizing,
      makeViewController: {
        ShuffleViewController()
      },
      remove: { [weak self] in
        self?.state.showShuffle = false
      })
  }

}
