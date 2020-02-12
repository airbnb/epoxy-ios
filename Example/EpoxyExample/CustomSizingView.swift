// Created by Cal Stephens on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

final class CustomSizingView: UIView {

  init() {
    super.init(frame: .zero)
    setUpViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    if bounds.size != intrinsicContentSize {
      invalidateIntrinsicContentSize()
    }
  }

  /// Some arbitrary self-sizing that relies on `frame.width`
  override var intrinsicContentSize: CGSize {
    let width = frame.width
    return CGSize(width: width, height: width * 0.3)
  }

  private func setUpViews() {
    let titleLabel = UILabel()
    titleLabel.text = "Self-sizing View"
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(titleLabel)

    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

}
