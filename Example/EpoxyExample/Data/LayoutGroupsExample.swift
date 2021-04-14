// Created by Tyler Hedrick on 4/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation

enum LayoutGroupsExample: CaseIterable {
  case readmeExamples
  case textRowExample
  case colors
  case messages
  case messagesUIStackView
  case todoList
  case entirelyInline
  case complex

  var title: String {
    switch self {
    case .readmeExamples:
      return "Readme examples"
    case .textRowExample:
      return "Text rows"
    case .colors:
      return "Group alignments"
    case .messages:
      return "Message list"
    case .messagesUIStackView:
      return "Message list (UIStackView)"
    case .todoList:
      return "Todo List"
    case .entirelyInline:
      return "Inline components"
    case .complex:
      return "Shuffle"
    }
  }

  var body: String {
    switch self {
    case .readmeExamples:
      return "All of the examples from the EpoxyLayoutGroups readme"
    case .textRowExample:
      return "Text rows with various alignments used in the titles"
    case .colors:
      return "A set of examples that show how group alignments affect subviews"
    case .messages:
      return "A list of message thread rows created using EpoxyLayoutGroups"
    case .messagesUIStackView:
      return "A list of message thread rows created using UIStackView to showcase the difference in API"
    case .todoList:
      return "A sample todo list"
    case .entirelyInline:
      return "An example showcasing creating components inline in an EpoxyCollectionView ItemModel"
    case .complex:
      return "An example showing how groups handle updates to the contained items"
    }
  }

}
