// Created by eric_horacek on 9/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import SwiftUI
import UIKit

// MARK: - EpoxyInSwiftUIViewController

final class EpoxyInSwiftUIViewController: UIHostingController<EpoxyInSwiftUIView> {
  init() {
    super.init(rootView: EpoxyInSwiftUIView())
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - EpoxyInSwiftUIView

struct EpoxyInSwiftUIView: View {
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(1...100, id: \.self) { index in
          TextRow.swiftUIView(
            content: .init(title: "Row \(index)", body: BeloIpsum.sentence(count: 1, wordCount: index)),
            style: .small)
            .onTapGesture {
              print("Row \(index) tapped!")
            }
        }
      }
    }
  }
}
