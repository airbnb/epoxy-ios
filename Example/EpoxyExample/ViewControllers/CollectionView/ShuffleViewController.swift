// Created by Logan Shire on 1/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class ShuffleViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setSections(sections, animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    addTimer()
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
    didSet { setSections(sections, animated: true) }
  }

  private var sections: [SectionModel] {
    state.sections.map { section in
      SectionModel(
        dataID: section.id,
        items: section.itemIDs.map { itemID in
          TextRow.itemModel(
            dataID: itemID,
            content: .init(
              title: "Section \(section.id), Row \(itemID)",
              body: BeloIpsum.paragraph(count: 1, seed: itemID)),
            style: .small)
            .didSelect { _ in
              // swiftlint:disable:next no_direct_standard_out_logs
              print("Selected section \(section.id), Row \(itemID)")
            }
        })
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
