// Created by Tyler Hedrick on 3/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyLayoutGroups
import UIKit

final class ComplexDeclarativeViewController: UIViewController {

  // MARK: Lifecycle

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .systemBackground
    scrollView.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
    view.addSubview(scrollView)
    scrollView.constrainToSuperview()

    group.install(in: scrollView)
    NSLayoutConstraint.activate([
      group.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
      group.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
      group.topAnchor.constraint(greaterThanOrEqualTo: scrollView.layoutMarginsGuide.topAnchor),
      group.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.layoutMarginsGuide.bottomAnchor),
      group.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
    ])

    updateGroup()
  }

  // MARK: Private

  private enum DataID {
    case button
    case spacer
  }

  private lazy var group = VGroup(alignment: .fill, spacing: 8)

  private func updateGroup() {
    group.setItems({
      Button.groupItem(
        dataID: DataID.button,
        content: .init(title: "Shuffle"),
        behaviors: .init { [weak self] _ in
          self?.updateGroup()
        },
        style: .init())
      randomColorItems()
    }, animated: true)
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
    let textStyles: [UIFont.TextStyle] = [
      .title2,
      .title3,
      .body,
    ]

    return allIndicies.map { index in
      let color = possibleItems[index]
      let textStyle = textStyles.randomElement() ?? .title3
      return HGroupItem(
        dataID: color.0,
        style: .init(spacing: 8))
      {
        Label.groupItem(
          dataID: color.0 + "label",
          content: color.0,
          style: .style(with: textStyle))
        SpacerItem(dataID: DataID.spacer)
        ColorView.groupItem(
          dataID: color.1,
          style: .init(size: .init(width: 44, height: 44), color: color.1))
      }
    }
  }

}
