// Created by Tyler Hedrick on 11/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit
import XCTest

extension UILabel {
  static var example: UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "This is a label"
    return label
  }
}

final class TestView: UIView, EpoxyableView {
  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    widthAnchor.constraint(equalToConstant: 50).isActive = true
    heightAnchor.constraint(equalToConstant: 50).isActive = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class TestLabel: UILabel, EpoxyableView {
  
  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  struct Content: Equatable {
    let text: String
  }

  func setContent(_ content: Content, animated: Bool) {
    text = content.text
  }
}

final class TestStyledLabel: UILabel, EpoxyableView {

  init(style: Style) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    font = .preferredFont(forTextStyle: style.textStyle)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  struct Style: Hashable {
    let textStyle: UIFont.TextStyle
  }

  typealias Content = String

  func setContent(_ content: String, animated: Bool) {
    text = content
  }
}

extension XCTestCase {

  // MARK: Internal

  /// Measures the average time taken for a `block` to run by running it
  /// 10 times and taking the average. This is similar to the built in
  /// `measure` function on XCTest but returns the result to allow for comparisons
  func measureAverageTime(_ block: () -> Void) -> Double {
    // run the block 10 times and take the average
    (0..<10).map { _ in measureAbsoluteTime(block) }.reduce(0, +) / 10
  }

  // MARK: Private

  private func measureAbsoluteTime(_ block: () -> Void) -> Double {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let end = CFAbsoluteTimeGetCurrent()
    return Double(end - start)
  }
}
