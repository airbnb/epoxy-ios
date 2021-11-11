// Created by Tyler Hedrick on 11/11/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class DynamicLayoutGroupsViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    setItems(items, animated: false)
  }

  // MARK: Private

  private enum DataID: CaseIterable {
    case row1
    case row2
    case row3
  }

  private var openOptions: [AnyHashable: Bool] = [:]

  @ItemModelBuilder
  private var items: [ItemModeling] {
    for id in DataID.allCases {
      DynamicRow.itemModel(
        dataID: id,
        content: .init(
          title: "Want to know more?",
          subtitle: "Tap below to reveal a set of options you can choose from",
          revealOptionsButton: openOptions(id) ? nil : "Reveal options",
          options: options(for: id),
          footer: "Thank you"),
        behaviors: .init(didTapRevealOptions: { [weak self] in
          self?.openOptions[id] = true
          self?.updateData()
        }, didTapOption: { [weak self] option in
          print("Selected option \(option)")
          self?.openOptions[id] = false
          self?.updateData()
        }))
    }
  }

  private func updateData() {
    setItems(items, animated: true)
  }

  private func openOptions(_ dataID: AnyHashable) -> Bool {
    openOptions[dataID] ?? false
  }

  private func options(for dataID: AnyHashable) -> [String]? {
    if openOptions(dataID) {
      return [
        "Option 1",
        "Option 2",
        "Option 3",
        "Option 4",
        "Option 5",
      ]
    }
    return nil
  }

}
