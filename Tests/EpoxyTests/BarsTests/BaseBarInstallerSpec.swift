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
    -> (container: InternalBarContainer, setBars: ([BarModeling]) -> Void)
}

// MARK: Spec implementation

extension BaseBarInstallerSpec {

  func baseSpec() {
    let defaultSafeAreaInset: CGFloat = 20
    var window: UIWindow!
    var viewController: UIViewController!
    var configuration: BarInstallerConfiguration!
    var container: InternalBarContainer!
    var setBars: (([BarModeling]) -> Void)!

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
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))
        }

        it("updates to 200pt inset when updating bar height") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))

          setBars([StaticHeightBar.barModel(style: .init(height: 200 + defaultSafeAreaInset))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(200))
        }

        it("doesn't override custom inset when using .none") {
          container.insetBehavior = .none
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(0))

          viewController.additionalSafeAreaInsets[keyPath: container.position.inset] = 50
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(50))
        }

        it("sets inset to 0 when changing from .barHeightSafeArea to .none") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))

          container.insetBehavior = .none
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(0))
        }

        it("sets layout margins when insetMargins=true") {
          container.insetMargins = true
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))])
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(defaultSafeAreaInset))
        }

        it("doesn't set layout margins when insetMargins=false") {
          container.insetMargins = false
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))])
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(0))
        }

        it("clears layout margins when changing from insetMargins=true to insetMargins=true") {
          container.insetMargins = true
          setBars([StaticHeightBar.barModel(style: .init(height: 100 + defaultSafeAreaInset))])
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(defaultSafeAreaInset))

          container.insetMargins = false
          expect(container.layoutMargins[keyPath: container.position.inset]).toEventually(equal(0))
        }
      }
    }

    describe("BarInstallerConfiguration") {
      context("with a non-nil applyBarModels") {
        var didApply: Bool!

        beforeEach {
          didApply = false

          configuration = BarInstallerConfiguration(applyBarModels: { apply in
            didApply = true
            apply()
          })

          (container, setBars) = self.installBarContainer(in: viewController, configuration: configuration)
        }

        afterEach {
          didApply = nil
        }

        context("with the initial bars") {
          it("should not call the applyBarModels closure") {
            expect(didApply) == false
          }
        }

        context("when setting subsequent bars") {
          beforeEach {
            setBars([StaticHeightBar.barModel(style: .init(height: 100))])
          }

          it("should call the applyBarModels closure") {
            expect(didApply) == true
          }

          it("should apply the bars") {
            expect(container.barViews).to(haveCount(1))
          }
        }
      }
    }
  }

}
