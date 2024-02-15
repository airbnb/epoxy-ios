// Created by Bryn Bodayle on 2/5/24.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import Epoxy
import SwiftUI
import UIKit

// MARK: - EpoxyInSwiftUISizingStrategiesViewViewController

/// Demo of the various sizing strategies for UIKit views bridged to SwiftUI
final class EpoxyInSwiftUISizingStrategiesViewController: UIHostingController<EpoxyInSwiftUISizingStrategiesView> {
  init() {
    super.init(rootView: EpoxyInSwiftUISizingStrategiesView())
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - EpoxyInSwiftUIView

struct EpoxyInSwiftUISizingStrategiesView: View {
  let text = "The text"
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 12) {
        Text("Word Count: \(wordCount)")
          .padding()
        Slider(value: $wordCount, in: 0...100)
          .padding()
        Text("Proposed Width/Height set to 150pt")
          .padding()

        ForEach(SwiftUIMeasurementContainerStrategy.allCases) { value in
          Text(value.displayString)
            .bold()
            .padding()
          LabelView(
            text: BeloIpsum.sentence(count: 1, wordCount: Int(wordCount)),
            measurementStrategy: value)
            .frame(width: value.proposedWidth, height: value.proposedHeight)
          .border(.red)
        }
      }
    }
  }

  @State private var wordCount = 12.0
}

extension SwiftUIMeasurementContainerStrategy: Identifiable, CaseIterable {
  public static var allCases: [SwiftUIMeasurementContainerStrategy] = [
    .automatic,
    .proposed,
    .intrinsicHeightProposedOrIntrinsicWidth,
    .intrinsicHeightProposedWidth,
    .intrinsicWidthProposedHeight,
    .intrinsic
  ]

  public var id: Self {
    self
  }

  var displayString: String {
    switch self {
    case .automatic:
      "Automatic"
    case .proposed:
      "Proposed"
    case .intrinsicHeightProposedOrIntrinsicWidth:
      "Intrinsic Height, Proposed Width or Intrinsic Width"
    case .intrinsicHeightProposedWidth:
      "Intrinsic Height, Proposed Width"
    case .intrinsicWidthProposedHeight:
      "Intrinsic Width, Proposed Height"
    case .intrinsic:
      "Intrinsic"
    }
  }

  var proposedWidth: CGFloat? {
    switch self {
    case .proposed, .intrinsicHeightProposedWidth:
      return 150
    default:
      return nil
    }
  }

  var proposedHeight: CGFloat? {
    switch self {
    case .proposed, .intrinsicWidthProposedHeight:
      return 150
    default:
      return nil
    }
  }
}

struct LabelView: UIViewConfiguringSwiftUIView {

  let text: String?
  let measurementStrategy: SwiftUIMeasurementContainerStrategy

  var configurations = [SwiftUIView<UILabel, Void>.Configuration]()

  var body: some View {
    UILabel.swiftUIView {
      let label = UILabel(frame: .zero)
      label.numberOfLines = 0
      return label
    }
    .configure { context in
      context.view.text = text
      context.container.invalidateIntrinsicContentSize()
    }
    .configurations(configurations)
    .sizing(measurementStrategy)
  }
}
