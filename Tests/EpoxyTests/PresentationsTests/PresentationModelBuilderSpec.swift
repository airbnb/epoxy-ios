// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit

@testable import EpoxyPresentations

final class PresentationModelBuilderSpec: QuickSpec {
  struct TestBuilder {
    init(@PresentationModelBuilder _ build: @escaping () -> PresentationModel?) {
      model = build()
    }
    var model: PresentationModel?
  }

  override func spec() {
    context("with a single presentation model expression") {
      it("should build the first presentation") {
        let builder = TestBuilder {
          PresentationModel(
            dataID: "1",
            presentation: .system,
            makeViewController: UIViewController.init,
            dismiss: {})
        }
        expect(builder.model?.dataID as? String) == "1"
      }
    }

    context("with multiple presentation model expressions") {
      it("should build the first presentation") {
        let builder = TestBuilder {
          PresentationModel(
            dataID: "1",
            presentation: .system,
            makeViewController: UIViewController.init,
            dismiss: {})
          PresentationModel(
            dataID: "2",
            presentation: .system,
            makeViewController: UIViewController.init,
            dismiss: {})
        }
        expect(builder.model?.dataID as? String) == "1"
      }
    }

    context("with an optional presentation model expression") {
      context("that evaluates to a non-nil value") {
        it("should build the first non-nil presentation") {
          let optionalPresentation: PresentationModel? = PresentationModel(
            dataID: "1",
            presentation: .system,
            makeViewController: UIViewController.init,
            dismiss: {})
          let builder = TestBuilder {
            optionalPresentation
            PresentationModel(
              dataID: "2",
              presentation: .system,
              makeViewController: UIViewController.init,
              dismiss: {})
          }
          expect(builder.model?.dataID as? String) == "1"
        }
      }

      context("that evaluates to a nil value") {
        it("should build the first non-nil presentation") {
          let optionalPresentation: PresentationModel? = nil
          let builder = TestBuilder {
            optionalPresentation
            PresentationModel(
              dataID: "2",
              presentation: .system,
              makeViewController: UIViewController.init,
              dismiss: {})
          }
          expect(builder.model?.dataID as? String) == "2"
        }
      }
    }

    context("with an if condition") {
      context("when the condition is false") {
        it("should build the first conditional presentation") {
          let condition = false
          let builder = TestBuilder {
            if condition {
              PresentationModel(
                dataID: "1",
                presentation: .system,
                makeViewController: UIViewController.init,
                dismiss: {})
            }
            PresentationModel(
              dataID: "2",
              presentation: .system,
              makeViewController: UIViewController.init,
              dismiss: {})
          }
          expect(builder.model?.dataID as? String) == "2"
        }
      }

      context("when the condition is true") {
        it("should build the first conditional presentation") {
          let condition = true
          let builder = TestBuilder {
            if condition {
              PresentationModel(
                dataID: "1",
                presentation: .system,
                makeViewController: UIViewController.init,
                dismiss: {})
            }
            PresentationModel(
              dataID: "2",
              presentation: .system,
              makeViewController: UIViewController.init,
              dismiss: {})
          }
          expect(builder.model?.dataID as? String) == "1"
        }
      }
    }

    context("with an if-else condition") {
      context("when the condition is false") {
        it("should build the first conditional presentation") {
          let condition = false
          let builder = TestBuilder {
            if condition {
              PresentationModel(
                dataID: "1",
                presentation: .system,
                makeViewController: UIViewController.init,
                dismiss: {})
            } else {
              PresentationModel(
                dataID: "2",
                presentation: .system,
                makeViewController: UIViewController.init,
                dismiss: {})
            }
          }
          expect(builder.model?.dataID as? String) == "2"
        }
      }

      context("when the condition is true") {
        it("should build the first conditional presentation") {
          let condition = true
          let builder = TestBuilder {
            if condition {
              PresentationModel(
                dataID: "1",
                presentation: .system,
                makeViewController: UIViewController.init,
                dismiss: {})
            } else {
              PresentationModel(
                dataID: "2",
                presentation: .system,
                makeViewController: UIViewController.init,
                dismiss: {})
            }
          }
          expect(builder.model?.dataID as? String) == "1"
        }
      }
    }

    // Result builders only work with for loops in Swift 5.4+
    #if swift(>=5.4)
    context("with a for loop") {
      it("should build the first non-nil presentation") {
        let builder = TestBuilder {
          for dataID in 1...10 where dataID % 2 == 0 {
            PresentationModel(
              dataID: dataID,
              presentation: .system,
              makeViewController: UIViewController.init,
              dismiss: {})
          }
        }
        expect(builder.model?.dataID as? Int) == 2
      }
    }
    #endif

    context("with no presentation models") {
      it("should build a nil model") {
        let builder = TestBuilder {}
        expect(builder.model).to(beNil())
      }
    }
  }
}
