// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

final class ImageRow: UIView {

  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    setUp()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var content: ImageRowContent? {
    didSet {
      guard let content = content else { return }
      titleLabel.text = content.title
      subtitleLabel.text = content.subtitle
      imageView.setURL(content.imageURL)
    }
  }

  // MARK: Private

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.preferredFont(forTextStyle: .title2)
    label.numberOfLines = 2
    return label
  }()

  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.numberOfLines = 0
    return label
  }()

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 4
    imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return imageView
  }()

  private lazy var labelStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()

  private func setUp() {
    addSubview(labelStackView)
    addSubview(imageView)
    let imageBottomConstraint = imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    imageBottomConstraint.priority = .defaultLow
    NSLayoutConstraint.activate([
      imageBottomConstraint,
      imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      labelStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
      labelStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      labelStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      labelStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    ])
    layoutMargins = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
  }
}

struct ImageRowContent: Equatable {
  let title: String
  let subtitle: String
  let imageURL: URL
}
