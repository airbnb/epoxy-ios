// Created by eric_horacek on 9/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import SwiftUI
import UIKit

// MARK: - EpoxyToSwiftUIViewController

final class EpoxyToSwiftUIViewController: UIHostingController<EpoxyToSwiftUIView> {
  init() {
    super.init(rootView: EpoxyToSwiftUIView())
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - EpoxyToSwiftUIView

struct EpoxyToSwiftUIView: View {
  @State var count = 0

  var body: some View {
    ScrollView {
      LazyVStack {
        TextRow.swiftUIView(content: .init(title: "Title", body: "Subtitle"), style: .large)
        TextRow.swiftUIView(content: .init(title: "Title", body: "Subtitle"), style: .small)
        ButtonRow.swiftUIView(
          content: .init(text: "Button (\(String(count)))"),
          behaviors: .init(didTap: {
            count += 1
          }))
        ImageRow.swiftUIView(
          content: .init(
            title: "Here is our exciting product",
            subtitle: "We think you should buy it.",
            imageURL: URL(string: "https://picsum.photos/id/350/500/500")!))
      }
    }
  }
}
