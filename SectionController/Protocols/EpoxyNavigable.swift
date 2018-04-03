//
//  EpoxyNavigable.swift
//  Epoxy
//
//  Created by Laura Skelton on 3/29/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

import UIKit

public protocol EpoxyNavigable: class {
  func navigate(toViewController viewController: UIViewController)
}

extension UIViewController: EpoxyNavigable {
  public func navigate(toViewController viewController: UIViewController) {
    if let navigationController = self as? UINavigationController {
      navigationController.pushViewController(viewController, animated: true)
    }
    navigationController?.pushViewController(viewController, animated: true)
  }
}
