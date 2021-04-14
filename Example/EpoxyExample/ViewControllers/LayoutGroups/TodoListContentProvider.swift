// Created by Tyler Hedrick on 1/28/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import Foundation

// MARK: - TodoItem

struct TodoItem {
  let id = UUID()
  let title: String
  let notes: String
  var isComplete: Bool
}

// MARK: - TodoListContentProvider

struct TodoListContentProvider: ContentProvider {

  var title: String { "Todo List" }

  var items: [ItemModeling] {
    demoItems.map { item in
      CheckboxRow.itemModel(
        dataID: item.id,
        content: .with(todoItem: item))
    }
  }

  // MARK: Private

  private var demoItems: [TodoItem] {
    [
      .init(title: "Laundry", notes: "Make sure the laundry is washed and folded", isComplete: false),
      .init(title: "Make the bed", notes: "Do this first thing after waking up!", isComplete: false),
      .init(title: "Buy Groceries", notes: "Eggs, milk, cheese, bread", isComplete: false),
      .init(title: "Build iOS App", notes: "Using LayoutGroups to make my layout fun and easy!", isComplete: true),
    ]
  }

}
extension CheckboxRow.Content {
  static func with(todoItem: TodoItem) -> CheckboxRow.Content {
    .init(
      title: todoItem.title,
      subtitle: todoItem.notes,
      isChecked: todoItem.isComplete)
  }
}
