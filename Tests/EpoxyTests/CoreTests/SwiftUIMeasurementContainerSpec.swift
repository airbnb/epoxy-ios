// Created by Sutheesh Sukumaran on 4/30/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

#if canImport(SwiftUI)
import Nimble
import Quick
import SwiftUI
import UIKit

// MARK: - SwiftUIMeasurementContainerSpec

final class SwiftUIMeasurementContainerSpec: QuickSpec {
  override func spec() {
    describe("SwiftUIMeasurementContainer") {

      describe("debouncesLayoutInvalidation") {
        afterEach {
          // Always reset to default after each test
          SwiftUIMeasurementContainer<TestView>.debouncesLayoutInvalidation = true
        }

        it("defaults to true") {
          expect(SwiftUIMeasurementContainer<TestView>.debouncesLayoutInvalidation).to(beTrue())
        }

        it("suppresses immediate re-layout when bounds change rapidly") {
          let container = SwiftUIMeasurementContainer(content: TestView(), strategy: .automatic)

          // First layout sets latestMeasurementBoundsSize
          container.layoutIfNeeded()

          // Simulate rapid bounds changes on the main thread (as UIKit requires)
          for i in 1...10 {
            container.frame = CGRect(x: 0, y: 0, width: CGFloat(100 + i), height: 100)
          }

          // With debouncing, needsLayout should be pending but deferred
          // The deferred selector fires after the current run-loop pass
          waitUntil(timeout: .milliseconds(200)) { done in
            DispatchQueue.main.async {
              // After the run-loop processes the deferred call, container should have
              // updated its intrinsic content size
              expect(container.intrinsicContentSize).notTo(equal(CGSize.noIntrinsicMetric))
              done()
            }
          }
        }

        it("falls back to immediate invalidation when disabled") {
          SwiftUIMeasurementContainer<TestView>.debouncesLayoutInvalidation = false

          let container = SwiftUIMeasurementContainer(content: TestView(), strategy: .automatic)

          // First layout sets latestMeasurementBoundsSize
          container.layoutIfNeeded()

          // Change bounds — with debouncing off, this should trigger immediate invalidation
          container.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
          container.layoutSubviews()

          // Intrinsic size is immediately invalidated (noIntrinsicMetric until next measure)
          expect(container.intrinsicContentSize).to(equal(CGSize.noIntrinsicMetric))
        }
      }

      describe("intrinsic content size measurement") {
        it("returns noIntrinsicMetric before first measurement") {
          let container = SwiftUIMeasurementContainer(content: TestView(), strategy: .automatic)
          expect(container.intrinsicContentSize).to(equal(CGSize.noIntrinsicMetric))
        }

        it("reflects the proposed size for .proposed strategy") {
          let container = SwiftUIMeasurementContainer(content: TestView(), strategy: .proposed)
          container.proposedSize = CGSize(width: 200, height: 150)
          let size = container.measuredFittingSize
          expect(size.width).to(equal(200))
          expect(size.height).to(equal(150))
        }
      }
    }
  }
}

// MARK: - TestView

private final class TestView: UIView {
  override var intrinsicContentSize: CGSize {
    CGSize(width: 100, height: 100)
  }
}

#endif
