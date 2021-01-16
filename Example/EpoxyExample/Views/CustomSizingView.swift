// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class CustomSizingView: UIView, EpoxyableView {

  // MARK: Lifecycle

  init() {
    super.init(frame: .zero)
    setUpViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.preferredContentSizeCategory != .unspecified
      && previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
    {
      sizingLabel.invalidateIntrinsicContentSize()
    }
  }

  // MARK: Private

  // Because this component has an intrinsicContentSize calculation based on its width, it requires
  // a second layout pass. Only UILabel will receive this second layout pass from the table /
  // collection view.
  private let sizingLabel = SizingLabel()

  private func setUpViews() {
    sizingLabel.numberOfLines = 0
    sizingLabel.contentSize = { width in
      return CGSize(width: width, height: width * 0.3)
    }
    sizingLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(sizingLabel)

    let titleLabel = UILabel()
    titleLabel.text = "Self-sizing View"
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(titleLabel)

    NSLayoutConstraint.activate([
      sizingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      sizingLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      sizingLabel.topAnchor.constraint(equalTo: topAnchor),
      sizingLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

}

// MARK: - SizingLabel

private class SizingLabel: UILabel {

  var contentSize: ((CGFloat) -> CGSize)?
  override var intrinsicContentSize: CGSize {
    let constrainingWidth: CGFloat
    if preferredMaxLayoutWidth != 0 {
      constrainingWidth = preferredMaxLayoutWidth
    } else {
      constrainingWidth = super.intrinsicContentSize.width
    }

    return contentSize?(constrainingWidth) ?? .zero
  }

  override func draw(_ rect: CGRect) {
    // Do nothing here, the label is only used for sizing
  }
}
