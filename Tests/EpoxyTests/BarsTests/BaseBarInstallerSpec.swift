// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit

@testable import EpoxyBars

// MARK: - BaseBarInstallerSpec

protocol BaseBarInstallerSpec {
  func installBarContainer(in viewController: UIViewController)
    -> (container: InternalBarContainer, setBars: ([BarModeling]) -> Void)
}

// MARK: Spec implementation

extension BaseBarInstallerSpec {
  
  func baseSpec() {
    var window: UIWindow!
    var viewController: UIViewController!
    var container: InternalBarContainer!
    var setBars: (([BarModeling]) -> Void)!

    beforeEach {
      window = UIWindow(frame: .init(origin: CGPoint(x: 0, y: 100), size: CGSize(width: 300, height: 300)))
      viewController = UIViewController()
      viewController.loadView()
      viewController.view.frame = window.bounds

      window.rootViewController = viewController
      window.makeKeyAndVisible()

      (container, setBars) = self.installBarContainer(in: viewController)
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
          setBars([StaticHeightBar.barModel(style: .init(height: 100))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))
        }

        it("updates to 200pt inset when updating bar height") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(style: .init(height: 100))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))

          setBars([StaticHeightBar.barModel(style: .init(height: 200))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(200))
        }

        it("doesn't override custom inset when using .none") {
          container.insetBehavior = .none
          setBars([StaticHeightBar.barModel(style: .init(height: 100))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(0))

          viewController.additionalSafeAreaInsets[keyPath: container.position.inset] = 50
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(50))
        }

        it("sets inset to 0 when changing from .barHeightSafeArea to .none") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(style: .init(height: 100))])
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(100))

          container.insetBehavior = .none
          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).toEventually(equal(0))
        }
      }
    }
  }

}
