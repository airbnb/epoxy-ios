// Created by eric_horacek on 1/18/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class ImageMarquee: UIView, EpoxyableView {

  // MARK: Lifecycle

  init(style: Style) {
    self.style = style
    super.init(frame: .zero)
    contentMode = style.contentMode
    clipsToBounds = true
    addSubviews()
    constrainSubviews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Style: Hashable {
    var height: CGFloat
    var contentMode: UIView.ContentMode
  }

  struct Content: Equatable {
    var imageURL: URL?
  }

  func setContent(_ content: Content, animated: Bool) {
    imageView.setURL(content.imageURL)
  }

  // MARK: Private

  private let style: Style
  private let imageView = UIImageView()

  private func addSubviews() {
    addSubview(imageView)
  }

  private func constrainSubviews() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    let heightAnchor = imageView.heightAnchor.constraint(equalToConstant: style.height)
    heightAnchor.priority = .defaultHigh
    NSLayoutConstraint.activate([
      heightAnchor,
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

}
