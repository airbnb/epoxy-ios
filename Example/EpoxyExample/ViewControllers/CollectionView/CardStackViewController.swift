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
          // Inlining this URL initializer causes SwiftLint to error for some reason
          let imageURL = URL(string: "https://picsum.photos/id/\(dataID + 310)/600/300")!
          return CardContainer<BarStackView>.itemModel(
            dataID: dataID,
            content: .init(
              models: [
                ImageMarquee.barModel(
                  // swiftlint:disable:next force_unwrapping
                  content: .init(imageURL: imageURL),
                  style: .init(height: 150, contentMode: .scaleAspectFill))
                  .didSelect { _ in
                    // swiftlint:disable:next no_direct_standard_out_logs
                    print("Selected Image Marquee \(dataID)")
                  },
                TextRow.barModel(
                  content: .init(title: "Row \(dataID)", body: BeloIpsum.paragraph(count: 1, seed: dataID)),
                  style: .small)
                  .didSelect { _ in
                    // swiftlint:disable:next no_direct_standard_out_logs
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
