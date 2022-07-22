// Created by eric_horacek on 9/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import SwiftUI
import UIKit

// MARK: - SwiftUIInEpoxyViewController

/// An example view controller that renders an scrollable list of SwiftUI text rows in an Epoxy
/// container.
final class SwiftUIInEpoxyViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setItems(items, animated: false)
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.install()
  }

  // MARK: Private

  private lazy var bottomBarInstaller = BottomBarInstaller(viewController: self, bars: bars)

  private var items: [ItemModeling] {
    (1...100).map { (index: Int) in
      SwiftUITextRow(title: "Row \(index)", subtitle: BeloIpsum.sentence(count: 1, wordCount: index))
        // swiftlint:disable:next no_direct_standard_out_logs
        .onAppear { print("Row \(index) appeared") }
        // swiftlint:disable:next no_direct_standard_out_logs
        .onDisappear { print("Row \(index) disappeared") }
        .itemModel(dataID: index)
        .didSelect { _ in
          // swiftlint:disable:next no_direct_standard_out_logs
          print("Row \(index) tapped!")
        }
    }
  }

  @BarModelBuilder
  private var bars: [BarModeling] {
    Divider().barModel()
    SwiftUITextRow(title: "Bottom Bar", subtitle: BeloIpsum.sentence(count: 1, wordCount: 20))
      // swiftlint:disable:next no_direct_standard_out_logs
      .onAppear { print("Bottom bar appeared") }
      // swiftlint:disable:next no_direct_standard_out_logs
      .onDisappear { print("Bottom bar disappeared") }
      // Ensure that the background color underlaps the bottom safe area in the bottom bar.
      .epoxyLayoutMargins()
      .background(Color(.systemBackground))
      .barModel()
  }
}

// MARK: - SwiftUITextRow

/// An implementation of `TextRow` in SwiftUI.
struct SwiftUITextRow: View {
  var title: String
  var subtitle: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(Font.body)
        .foregroundColor(Color(.label))
      if let subtitle = subtitle {
        Text(subtitle)
          .font(Font.caption)
          .foregroundColor(Color(.secondaryLabel))
      }
    }
    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    // Ensure that the text is aligned to the leading edge of the container when it expands beyond
    // its ideal width, instead of the center (the default).
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
