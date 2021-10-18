// Created by eric_horacek on 10/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

extension UIViewController {
  static func makeReadmeExample(_ example: ReadmeExample) -> UIViewController {
    switch example {
    case .tapMe:
      return CollectionViewController.makeTapMeViewController()
    case .counter:
      return CounterViewController()
    case .bottomButton:
      return BottomButtonViewController()
    case .formNavigation:
      return FormNavigationController()
    case .modalPresentation:
      return PresentationViewController()
    }
  }
}
