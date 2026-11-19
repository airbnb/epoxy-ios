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

      context("when called from a bar's callback during an update") {
        var failures: [String]!
        var previousLogger: EpoxyLogger!

        beforeEach {
          failures = []
          previousLogger = EpoxyLogger.shared
          EpoxyLogger.shared = EpoxyLogger(assertionFailure: { message, _, _ in failures.append(message()) })
        }

        afterEach {
          EpoxyLogger.shared = previousLogger
        }

        context("with fewer bars from an updated bar") {
          it("should apply the nested call after the update and assert") {
            view.setBars([
              TestView.barModel(content: 1).dataID(1),
              TestView.barModel(content: 2).dataID(2),
              TestView.barModel(content: 3).dataID(3),
            ], animated: false)

            view.setBars([
              TestView.barModel(content: 1).dataID(1).setBehaviors { _ in
                view.setBars([
                  TestView.barModel(content: 2).dataID(2),
                  TestView.barModel(content: 3).dataID(3),
                ], animated: false)
              },
              TestView.barModel(content: 2).dataID(2),
              TestView.barModel(content: 3).dataID(3),
            ], animated: false)

            expect(view.arrangedBarViewTags).to(equal([2,3]))
            expect(view.models.map(\.dataID)).to(equal([2,3]))
            expect(failures).to(haveCount(1))
          }
        }

        context("with fewer bars from an inserted bar") {
          it("should apply the nested call after the update and assert") {
            view.setBars([
              TestView.barModel(content: 2).dataID(2),
              TestView.barModel(content: 3).dataID(3),
            ], animated: false)

            view.setBars([
              TestView.barModel(content: 1).dataID(1).setBehaviors { _ in
                view.setBars([TestView.barModel(content: 3).dataID(3)], animated: false)
              },
              TestView.barModel(content: 2).dataID(2),
              TestView.barModel(content: 3).dataID(3),
            ], animated: false)

            expect(view.arrangedBarViewTags).to(equal([3]))
            expect(view.models.map(\.dataID)).to(equal([3]))
            expect(failures).to(haveCount(1))
          }
        }

        context("with as many bars") {
          it("should apply the nested call after the update without asserting") {
            view.setBars([
              TestView.barModel(content: 1).dataID(1),
              TestView.barModel(content: 2).dataID(2),
            ], animated: false)

            view.setBars([
              TestView.barModel(content: 1).dataID(1).setBehaviors { _ in
                view.setBars([
                  TestView.barModel(content: 4).dataID(4),
                  TestView.barModel(content: 2).dataID(2),
                ], animated: false)
              },
              TestView.barModel(content: 2).dataID(2),
            ], animated: false)

            expect(view.arrangedBarViewTags).to(equal([4,2]))
            expect(failures).to(beEmpty())
          }
        }

        context("more than once") {
          it("should apply only the latest nested call") {
            view.setBars([
              TestView.barModel(content: 1).dataID(1),
              TestView.barModel(content: 2).dataID(2),
            ], animated: false)

            view.setBars([
              TestView.barModel(content: 1).dataID(1).setBehaviors { _ in
                view.setBars([TestView.barModel(content: 2).dataID(2)], animated: false)
                view.setBars([
                  TestView.barModel(content: 4).dataID(4),
                  TestView.barModel(content: 2).dataID(2),
                ], animated: false)
              },
              TestView.barModel(content: 2).dataID(2),
            ], animated: false)

            expect(view.arrangedBarViewTags).to(equal([4,2]))
          }
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
