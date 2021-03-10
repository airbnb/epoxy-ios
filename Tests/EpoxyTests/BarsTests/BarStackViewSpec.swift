// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit

import EpoxyCore
@testable import EpoxyBars

final class BarStackViewSpec: QuickSpec {
  override func spec() {
    let view = BarStackView()

    it("should contain views in the right order after content updates") {
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

      expect(view.childTags).to(equal([1,2,3,4]))

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

      expect(view.childTags).to(equal([10,2,30,4]))
    }
  }

  enum StyleID {
    case loading
    case loaded
  }

  final class TestView: UIView, EpoxyableView {
    init() {
      super.init(frame: .zero)
      widthAnchor.constraint(equalToConstant: 50).isActive = true
      heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func setContent(_ content: Int, animated: Bool) {
      tag = content
    }
  }
}


extension BarStackView {
  var childTags: [Int] {
    arrangedSubviews.compactMap { view in
      guard let wrapper = view as? BarWrapperView else { return nil }
      return wrapper.view?.tag
    }
  }
}
