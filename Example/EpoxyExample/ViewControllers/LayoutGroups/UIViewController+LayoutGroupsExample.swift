// Created by eric_horacek on 10/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

extension UIViewController {
  static func makeLayoutGroupsExample(_ example: LayoutGroupsExample) -> UIViewController {
    let viewController: UIViewController
    switch example {
    case .readmeExamples:
      viewController = LayoutGroupsReadmeExamplesViewController()
    case .textRowExample:
      viewController = TextRowExampleViewController()
    case .colors:
      viewController = ColorsViewController()
    case .messages:
      viewController = MessagesViewController()
    case .messagesUIStackView:
      viewController = MessagesUIStackViewViewController()
    case .todoList:
      viewController = TodoListViewController()
    case .entirelyInline:
      viewController = EntirelyInlineViewController()
    case .complex:
      viewController = ComplexDeclarativeViewController()
    }
    viewController.title = example.title
    return viewController
  }
}
