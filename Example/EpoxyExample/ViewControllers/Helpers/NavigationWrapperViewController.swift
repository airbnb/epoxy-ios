// Created by eric_horacek on 3/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

/// A naive implementation a Navigation wrapper so we can nest the `FormNavigationController`
/// without a UIKit crash.
///
/// You probably want a custom wrapper for your use cases.
final class NavigationWrapperViewController: UIViewController {
  init(navigationController: UINavigationController) {
    // A naive implementation of `wrapNavigation` so we can nest the `FormNavigationController`.
    navigationController.setNavigationBarHidden(true, animated: false)

    super.init(nibName: nil, bundle: nil)

    addChild(navigationController)
    view.addSubview(navigationController.view)
    navigationController.view.frame = view.bounds
    navigationController.view.translatesAutoresizingMaskIntoConstraints = true
    navigationController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    navigationController.didMove(toParent: self)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
