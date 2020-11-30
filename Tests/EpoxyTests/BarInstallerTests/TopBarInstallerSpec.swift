// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit

@testable import EpoxyBars

final class TopBarInstallerSpec: QuickSpec, BaseBarInstallerSpec {

  func installBarContainer(in viewController: UIViewController)
    -> (container: InternalBarContainer, setBars: ([BarModeling]) -> Void)
  {
    let barInstaller = TopBarInstaller(viewController: viewController)
    viewController.view.layoutIfNeeded()
    barInstaller.install()

    return (
      container: barInstaller.container!,
      setBars: { barInstaller.setBars($0, animated: false) })
  }

  override func spec() {
    baseSpec()
  }

}
