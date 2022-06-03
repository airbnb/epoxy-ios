// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit

@testable import EpoxyBars
import XCTest

final class BottomBarInstallerSpec: QuickSpec, BaseBarInstallerSpec {

  func installBarContainer(
    in viewController: UIViewController,
    configuration: BarInstallerConfiguration)
    -> (container: InternalBarContainer, setBars: ([BarModeling], Bool) -> Void)
  {
    let barInstaller = BottomBarInstaller(viewController: viewController, configuration: configuration)
    viewController.view.layoutIfNeeded()
    barInstaller.install()

    return (
      container: barInstaller.container!,
      setBars: { barInstaller.setBars($0, animated: $1) })
  }

  override func spec() {
    baseSpec()

    describe("BottomBarContainer") {
      it("has a reference to the BottomBarInstaller when installed") {
        let barInstaller = self.installedBar()

        expect(barInstaller.container?.barInstaller).toEventually(equal(barInstaller))

        barInstaller.uninstall()
        expect(barInstaller.container?.barInstaller).toEventually(beNil())
      }
    }

    describe("visibility") {
      it("of a bar and erased bar type") {
        let barModelWillDisplayExpectation = XCTestExpectation(description: "willDisplay should be called on the underlying bar model")
        let barModel = TestView
          .barModel()
          .willDisplay { _ in
            barModelWillDisplayExpectation.fulfill()
          }

        let anyBarModelWillDisplayExpectation = XCTestExpectation(description: "willDisplay should be called on AnyBarModel")
        let anyBarModel = AnyBarModel(barModel)
          .willDisplay { _ in
            anyBarModelWillDisplayExpectation.fulfill()
          }

        let barInstaller = self.installedBar()
        barInstaller.setBars([anyBarModel], animated: false)
        self.wait(for: [barModelWillDisplayExpectation, anyBarModelWillDisplayExpectation], timeout: 1.0)
      }
    }
  }

  private func installedBar() -> BottomBarInstaller {
    let viewController = UIViewController()
    viewController.loadView()
    let barInstaller = BottomBarInstaller(viewController: viewController)

    barInstaller.install()
    return barInstaller
  }

}
