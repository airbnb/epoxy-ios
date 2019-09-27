// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class HighlightAndSelectionViewController: EpoxyTableViewController {

  // MARK: EpoxyTableViewController

  override func epoxySections() -> [EpoxySection] {
    let items = [
      row(text: "Row 1", dataID: "1"),
      row(text: "Row 2", dataID: "2"),
      row(text: "Row 3", dataID: "3"),
      row(text: "Row 4", dataID: "4"),
      row(text: "Row 5", dataID: "5"),
      row(text: "Row 6", dataID: "6"),
      row(text: "Row 7", dataID: "7"),
      row(text: "Row 8", dataID: "8"),
      row(text: "Row 9", dataID: "9"),
      row(text: "Row 10", dataID: "10"),
    ]
    return [EpoxySection(items: items)]
  }

  // MARK: Private

  private func row(text: String, dataID: String) -> EpoxyableModel {
    return BaseEpoxyModelBuilder<Row, String>(
      data: text,
      dataID: dataID)
      .configureView { context in
        context.view.text = text
      }
      .didSelect { context in
        print("DataID selected \(context.dataID) (selection handler)")
      }
      .build()
  }

}

