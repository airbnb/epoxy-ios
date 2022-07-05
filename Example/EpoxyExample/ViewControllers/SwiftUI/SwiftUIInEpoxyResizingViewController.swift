// Created by eric_horacek on 7/5/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Epoxy
import SwiftUI
import UIKit

// MARK: - SwiftUIInEpoxyResizingViewController

/// An example view controller that renders an scrollable list of SwiftUI text rows in an Epoxy
/// container that can expand on tap.
final class SwiftUIInEpoxyResizingViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.listNoDividers)
    setItems(items, animated: false)
  }

  // MARK: Private

  private var items: [ItemModeling] {
    (1...100).map { (index: Int) in
      SwiftUIExpandableRow(title: "Row \(index)", subtitle: BeloIpsum.sentence(count: 1, wordCount: index))
        // Since each view has its own state, it needs its own reuse ID.
        .itemModel(dataID: index, reuseBehavior: .unique(reuseID: index))
    }
  }
}

// MARK: - SwiftUIExpandableRow

/// An implementation of `TextRow` in SwiftUI.
struct SwiftUIExpandableRow: View {
  var title: String
  var subtitle: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(Font.body)
        .foregroundColor(Color(.label))
      if isExpanded {
        Text(subtitle)
          .font(Font.caption)
          .foregroundColor(Color(.secondaryLabel))
          .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .animation(.default, value: isExpanded)
    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    // Ensure that the text is aligned to the leading edge of the container when it expands beyond
    // its ideal width, instead of the center (the default).
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
    .onTapGesture {
      isExpanded.toggle()
      invalidateIntrinsicContentSize()
    }
  }

  @State private var isExpanded = false
  @Environment(\.epoxyIntrinsicContentSizeInvalidator) var invalidateIntrinsicContentSize
}
