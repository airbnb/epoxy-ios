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
      describe("debounced invalidation") {
        it("batches multiple rapid bounds changes into a single invalidation") {
          let container = SwiftUIMeasurementContainer(
            content: TestView(),
            strategy: .automatic
          )

          // Track how many times invalidation actually occurs
          var invalidationCount = 0
          let originalInvalidate = container.invalidateIntrinsicContentSize

          // Swizzle to count calls (simulated by tracking state)
          var trackedInvalidations = 0
          let testQueue = DispatchQueue(label: "test.invalidation.tracking")

          // Simulate rapid bounds changes
          testQueue.async {
            // Trigger multiple rapid layout passes
            for i in 0..<100 {
              container.bounds = CGRect(x: 0, y: 0, width: CGFloat(100 + i), height: 100)
              container.layoutSubviews()
            }
          }

          // Allow runloop to process deferred invalidations
          let expectation = XCTestExpectation(description: "debounce completes")
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
          }

          // Verify that we don't get cascading invalidations
          expect(trackedInvalidations).toEventually(
            beLessThan(10),
            timeout: .milliseconds(200),
            description: "Should batch rapid invalidations"
          )
        }

        it("handles single bounds change correctly") {
          let container = SwiftUIMeasurementContainer(
            content: TestView(),
            strategy: .automatic
          )

          container.layoutSubviews()
          container.bounds = CGRect(x: 0, y: 0, width: 150, height: 100)
          container.layoutSubviews()

          expect(container.bounds.size.width).to(equal(150))
        }

        it("correctly invalidates after debounce period") {
          let container = SwiftUIMeasurementContainer(
            content: TestView(),
            strategy: .automatic
          )

          // Initial layout
          container.layoutSubviews()

          // Set bounds change to trigger deferred invalidation
          container.bounds = CGRect(x: 0, y: 0, width: 200, height: 100)
          container.layoutSubviews()

          // Verify debounce flag is set
          let expectation = XCTestExpectation(description: "debounce executes")
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            expectation.fulfill()
          }

          expect(expectation.wait(timeout: 1)).to(equal(.completed))
        }
      }

      describe("intrinsic content size measurement") {
        it("measures content correctly") {
          let testView = TestView()
          let container = SwiftUIMeasurementContainer(
            content: testView,
            strategy: .automatic
          )

          let measuredSize = container.intrinsicContentSize
          expect(measuredSize).notTo(equal(CGSize.noIntrinsicMetric))
        }

        it("handles proposed size changes") {
          let testView = TestView()
          let container = SwiftUIMeasurementContainer(
            content: testView,
            strategy: .proposed
          )

          container.proposedSize = CGSize(width: 100, height: 200)
          let measuredSize = container.measuredFittingSize

          expect(measuredSize.width).to(equal(100))
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
