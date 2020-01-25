// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    let tabBarController = UITabBarController()
    tabBarController.setViewControllers([
      HighlightAndSelectionViewController(),
      ShuffleViewController()
    ], animated: false)

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
    window?.rootViewController = tabBarController
    window?.makeKeyAndVisible()
    return true
  }

}

