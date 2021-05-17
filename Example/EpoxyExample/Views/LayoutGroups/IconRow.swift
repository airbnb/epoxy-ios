// Created by Tyler Hedrick on 2/5/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit

final class IconRow: BaseRow, EpoxyableView {

  // MARK: Lifecycle

  override init() {
    super.init()
    setUp()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Content: Equatable {
    let title: String
    let icon: UIImage
  }

  func setContent(_ content: Content, animated: Bool) {
    imageView.image = content.icon
    titleLabel.text = content.title
  }

  // MARK: Private

  private let imageView = IconView(
    image: nil,
    size: .init(width: 24, height: 24))
  private let titleLabel = Label(style: .style(with: .title2))

  private lazy var group = HGroup(spacing: 8) {
    StaticGroupItem(imageView)
    StaticGroupItem(titleLabel)
  }

  private func setUp() {
    imageView.tintColor = .black
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
  }

}
