// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    true
  }

  func application(
    _: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions)
    -> UISceneConfiguration
  {
    UISceneConfiguration(
      name: "Default Configuration",
      sessionRole: connectingSceneSession.role)
  }

  func application(
    _: UIApplication,
    didDiscardSceneSessions _: Set<UISceneSession>) { }
}
