// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import Nimble
import Quick
import UIKit

@testable import EpoxyBars

// MARK: - BarStackViewSpec

// swiftlint:disable implicitly_unwrapped_optional

final class BarStackViewSpec: QuickSpec {
  enum StyleID {
    case loading
    case loaded
  }

  final class TestView: UIView, EpoxyableView {

    // MARK: Lifecycle

    init() {
      super.init(frame: .zero)
      widthAnchor.constraint(equalToConstant: 50).isActive = true
      heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    func setContent(_ content: Int, animated _: Bool) {
      tag = content
    }
  }

  override func spec() {
    var view: BarStackView!
    beforeEach {
      view = BarStackView()
    }
    afterEach {
      view = nil
    }

    describe("setBars(_:animated:)") {
      context("when called with two different arrays of bar models") {
        it("should contain bar subviews representing the last array of bar models") {
          view.setBars([
            TestView.barModel(content: 1).styleID(StyleID.loading)
              .dataID(1),
            TestView.barModel(content: 2)
              .dataID(2),
            TestView.barModel(content: 3).styleID(StyleID.loading)
              .dataID(3),
            TestView.barModel(content: 4)
              .dataID(4),
          ], animated: false)

          expect(view.arrangedBarViewTags).to(equal([1,2,3,4]))

          view.setBars([
            TestView.barModel(content: 10).styleID(StyleID.loaded)
              .dataID(1),
            TestView.barModel(content: 2)
              .dataID(2),
            TestView.barModel(content: 30).styleID(StyleID.loaded)
              .dataID(3),
            TestView.barModel(content: 4)
              .dataID(4),
          ], animated: false)

          expect(view.arrangedBarViewTags).to(equal([10,2,30,4]))
        }
      }
    }
  }

}

extension BarStackView {
  var arrangedBarViewTags: [Int] {
    arrangedSubviews.compactMap { view in
      guard let wrapper = view as? BarWrapperView else { return nil }
      return wrapper.view?.tag
    }
  }
}
