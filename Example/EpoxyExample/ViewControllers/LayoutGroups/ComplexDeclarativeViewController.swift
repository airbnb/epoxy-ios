// Created by Tyler Hedrick on 3/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyLayoutGroups
import UIKit

final class ComplexDeclarativeViewController: UIViewController {

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
    view.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)

    group.install(in: view)
    NSLayoutConstraint.activate([
      group.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      group.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      group.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor),
      group.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor),
      group.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])

    updateGroup()
  }

  // MARK: Private

  private enum DataID {
    case button
    case spacer
  }

  private lazy var group = VGroup(alignment: .fill, spacing: 8)

  @objc
  private func updateGroup() {
    group.setItems {
      Button.groupItem(
        dataID: DataID.button,
        content: .init(title: "Shuffle"),
        behaviors: .init { [weak self] _ in
          self?.updateGroup()
        },
        style: .init())
      randomColorItems()
    }
  }

  private func randomColorItems() -> [GroupItemModeling] {
    let possibleItems = [
      ("Red", UIColor.systemRed),
      ("Orange", UIColor.systemOrange),
      ("Yellow", UIColor.systemYellow),
      ("Green", UIColor.systemGreen),
      ("Blue", UIColor.systemBlue),
      ("Purple", UIColor.systemPurple),
    ]
    let numberOfItems = Int.random(in: 1..<possibleItems.count)
    let allIndicies = Array(0...numberOfItems).shuffled()

    return allIndicies.map { index in
      let color = possibleItems[index]
      return HGroupItem(
        dataID: color.0,
        style: .init(spacing: 8))
      {
        Label.groupItem(
          dataID: color.0 + "label",
          content: color.0,
          style: .style(with: .title3))
        SpacerItem(dataID: DataID.spacer)
        ColorView.groupItem(
          dataID: color.1,
          style: .init(size: .init(width: 44, height: 44), color: color.1))
      }
    }
  }

}
