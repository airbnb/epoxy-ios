// Created by Logan Shire on 1/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class ShuffleViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout.listNoDividers)
    title = "Shuffle"
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    addTimer()
  }

  override func epoxySections() -> [SectionModel] {
    state.sections.map { section in
      SectionModel(
        dataID: section.id,
        items: section.itemIDs.map { itemID in
          Row.itemModel(
            dataID: itemID,
            content: .init(
              title: "Section \(section.id), Row \(itemID)",
              body: BeloIpsum.paragraph(count: 1, seed: itemID)),
            style: .small)
            .didSelect { context in
              print("Selected section \(section.id), Row \(itemID)")
            }
        })
    }
  }

  // MARK: Private

  private struct State {
    init() {
      randomize()
    }

    var sections = [(id: Int, itemIDs: [Int])]()

    mutating func randomize() {
      sections = (0..<3).shuffled().filter { _ in Int.random(in: 0..<3) != 0 }.map { id in
        let itemIDs = (0..<10).shuffled().filter { _ in Int.random(in: 0..<3) != 0 }
        return (id: id, itemIDs: itemIDs)
      }
    }
  }

  private var state = State() {
    didSet {
      updateData(animated: true)
    }
  }

  private func addTimer() {
    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
      guard let self = self else {
        timer.invalidate()
        return
      }
      self.state.randomize()
    }
  }

}
