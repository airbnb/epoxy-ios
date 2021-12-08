// Created by eric_horacek on 2/9/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class CardStackViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setSections(sections, animated: false)
  }

  // MARK: Private

  private var sections: [SectionModel] {
    (0..<10).map { (dataID: Int) in
      SectionModel(dataID: dataID) {
        (0..<10).map { (dataID: Int) in
          CardContainer<BarStackView>.itemModel(
            dataID: dataID,
            content: .init(
              models: [
                ImageMarquee.barModel(
                  // swiftlint:disable:next force_unwrapping
                  content: .init(imageURL: URL(string: "https://picsum.photos/id/\(dataID + 310)/600/300")!),
                  style: .init(height: 150, contentMode: .scaleAspectFill))
                  .didSelect { _ in
                    print("Selected Image Marquee \(dataID)")
                  },
                TextRow.barModel(
                  content: .init(title: "Row \(dataID)", body: BeloIpsum.paragraph(count: 1, seed: dataID)),
                  style: .small)
                  .didSelect { _ in
                    print("Selected Text Row \(dataID)")
                  },
              ],
              selectedBackgroundColor: .secondarySystemBackground),
            style: .init(card: .init()))
        }
      }
    }
  }
}
