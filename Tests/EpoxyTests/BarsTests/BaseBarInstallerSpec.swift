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
    var viewController: UIViewController!
    var container: InternalBarContainer!
    var setBars: (([BarModeling]) -> Void)!

    beforeEach {
      viewController = UIViewController()
      viewController.loadView()
      viewController.view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 600))

      (container, setBars) = self.installBarContainer(in: viewController)
      viewController.view.layoutIfNeeded()
    }

    afterEach {
      viewController = nil
      container = nil
      setBars = nil
    }

    describe("BarContainerInsetBehavior") {
      context("with a 100pt bar") {
        it("sets 100pt inset when using .barHeightSafeArea") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(height: 100)])
          container.layoutIfNeeded()

          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).to(equal(100))
        }

        it("updates to 200pt inset when updating bar height") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(height: 100)])
          container.layoutIfNeeded()

          setBars([StaticHeightBar.barModel(height: 200)])
          container.setNeedsLayout()
          container.layoutIfNeeded()

          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).to(equal(200))
        }

        it("doesn't override custom inset when using .none") {
          container.insetBehavior = .none
          setBars([StaticHeightBar.barModel(height: 100)])
          container.layoutIfNeeded()

          viewController.additionalSafeAreaInsets[keyPath: container.position.inset] = 50
          container.layoutIfNeeded()

          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).to(equal(50))
        }

        it("sets inset to 0 when changing from .barHeightSafeArea to .none") {
          container.insetBehavior = .barHeightSafeArea
          setBars([StaticHeightBar.barModel(height: 100)])
          container.layoutIfNeeded()

          container.insetBehavior = .none
          container.layoutIfNeeded()

          expect(viewController.additionalSafeAreaInsets[keyPath: container.position.inset]).to(equal(0))
        }
      }
    }
  }

}
