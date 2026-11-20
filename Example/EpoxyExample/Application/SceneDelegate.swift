// Created by nuomi1 on 11/20/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo _: UISceneSession,
    options _: UIScene.ConnectionOptions)
  {
    guard let windowScene = scene as? UIWindowScene else { return }

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = MainViewController()
    window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_: UIScene) {
    window = nil
  }
}
