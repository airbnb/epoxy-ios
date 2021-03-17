// Created by eric_horacek on 3/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

/// All examples from the README of this project.
enum ReadmeExample: CaseIterable {
  case tapMe
  case counter
  case bottomButton
  case formNavigation
  case modalPresentation

  // MARK: Internal

  var title: String {
    switch self {
    case .tapMe:
      return "Tap Me"
    case .counter:
      return "Counter"
    case .bottomButton:
      return "Bottom button"
    case .formNavigation:
      return "Form Navigation"
    case .modalPresentation:
      return "Modal Presentation"
    }
  }

  var body: String {
    switch self {
    case .tapMe, .counter:
      return "EpoxyCollectionView"
    case .bottomButton:
      return "EpoxyBars"
    case .formNavigation:
      return "EpoxyNavigationController"
    case .modalPresentation:
      return "EpoxyPresentations"
    }
  }
}
