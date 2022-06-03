// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit

@testable import EpoxyBars

// MARK: - BaseBarInstallerSpec

protocol BaseBarInstallerSpec {
  func installBarContainer(
    in viewController: UIViewController,
    configuration: BarInstallerConfiguration)
    -> (container: InternalBarContainer, setBars: ([BarModeling], Bool) -> Void)
}

// MARK: Spec implementation

extension BaseBarInstallerSpec {

  func baseSpec() {
    let defaultSafeAreaInset: CGFloat = 20
    var window: UIWindow!
    var viewController: UIViewController!
    var configuration: BarInstallerConfiguration!
    var container: InternalBarContainer!
    var setBars: (([BarModeling], Bool) -> Void)!

    beforeEach {
      window = SafeAreaWindow(
        frame: .init(origin: CGPoint(x: 0, y: 100), size: CGSize(width: 300, height: 300)),
        safeAreaInsets: UIEdgeInsets(top: defaultSafeAreaInset, left: 0, bottom: defaultSafeAreaInset, right: 0))

      viewController = UIViewController()
      viewController.loadView()
      viewController.view.frame = window.bounds

      configuration = BarInstallerConfiguration()

      window.rootViewController = viewController
      window.makeKeyAndVisible()

      (container, setBars) = self.installBarContainer(in: viewController, configuration: configuration)
    }

    afterEach {
      window = nil
      viewController = nil
      container = nil
      setBars = nil
    }

    describe("BarContainerInsetBehavior") {
      context("with a 100pt bar") {
        it("sets 100pt inset when using .barHeightSafeArea") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))], false)
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))
        }

        it("updates to 200pt inset when updating bar height") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))], false)
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))

          setBars([StaticHeightBar.barModel(style: .init(height: 200 + defaultSafeAreaInset))], false)
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(200))
        }

        it("doesn't override custom inset when using .none") {
          container.insetBehavior = .none
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))], false)
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(0))

          viewController.additionalSafeAreaInsets[keyPath: container.position.inset] = 50
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(50))
        }

        it("sets inset to 0 when changing from .barHeightSafeArea to .none") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))], false)
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))

          container.insetBehavior = .none
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(0))
        }

        it("sets layout margins when insetMargins=true") {
          container.insetMargins = true
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))], false)
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(defaultSafeAreaInset))
        }

        it("doesn't set layout margins when insetMargins=false") {
          container.insetMargins = false
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))], false)
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(0))
        }

        it("clears layout margins when changing from insetMargins=true to insetMargins=true") {
          container.insetMargins = true
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))], false)
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(defaultSafeAreaInset))

          container.insetMargins = false
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(0))
        }
      }
    }

    describe("BarModel and AnyBarModel visibility") {
      context("with willDisplay on BarModel and AnyBarModel") {
        it("calls willDisplay for both internal and erased types") {
          var barModelWillDisplayCount = 0
          let barModel = TestView
            .barModel()
            .willDisplay { _ in
              barModelWillDisplayCount += 1
            }

          var anyBarModelWillDisplayCount = 0
          let anyBarModel = AnyBarModel(barModel)
            .willDisplay { _ in
              anyBarModelWillDisplayCount += 1
            }

          setBars([anyBarModel], false)
          expect(barModelWillDisplayCount).toEventually(equal(1))
          expect(anyBarModelWillDisplayCount).toEventually(equal(1))
        }
      }

      context("with willDisplay only on BarModel") {
        it("only calls willDisplay once") {
          var barModelWillDisplayCount = 0
          let barModel = TestView
            .barModel()
            .willDisplay { _ in
              barModelWillDisplayCount += 1
            }

          setBars([barModel], false)
          expect(barModelWillDisplayCount).toEventually(equal(1))
        }
      }
    }

    describe("BarInstallerConfiguration") {
      context("with a non-nil applyBars") {
        var applications: [(container: BarContainer, bars: [BarModeling], animated: Bool)]!

        beforeEach {
          applications = []

          configuration = BarInstallerConfiguration(applyBars: { container, bars, animated in
            applications.append((container, bars, animated))
            container.setBars(bars, animated: animated)
          })

          (container, setBars) = self.installBarContainer(in: viewController, configuration: configuration)
        }

        afterEach {
          applications = nil
        }

        context("with the initial bars") {
          it("should not call the applyBars closure") {
            expect(applications).to(haveCount(0))
          }

          it("should not have applied any bars") {
            expect(container.barViews).to(haveCount(0))
          }
        }

        context("when setting subsequent bars") {
          let bars = [StaticHeightBar.barModel(style: .init(height: 100))]
          let animated = false

          beforeEach {
            setBars(bars, animated)
          }

          it("should call the applyBars closure") {
            expect(applications).to(haveCount(1))
          }

          it("should call the applyBars closure with the container") {
            expect(applications.first?.container) === container
          }

          it("should call the applyBars closure with the animated value") {
            expect(applications.first?.animated) == animated
          }

          it("should call the applyBars closure with the bars value") {
            let appliedBar = applications.first?.bars.first?.eraseToAnyBarModel()
            let bar = bars.first
            expect(appliedBar?.diffIdentifier) == bar?.diffIdentifier
          }

          it("should apply the bars") {
            expect(container.barViews).to(haveCount(1))
          }
        }
      }
    }
  }

}
