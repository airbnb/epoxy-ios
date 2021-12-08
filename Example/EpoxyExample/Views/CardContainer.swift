// Created by eric_horacek on 2/9/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - CardContainer

/// A container that draws a card around a content view.
final class CardContainer<ContentView: EpoxyableView>: UIView, EpoxyableView {

  // MARK: Lifecycle

  init(style: Style) {
    self.style = style.card
    if ContentView.Style.self == Never.self {
      contentView = ContentView()
    } else {
      contentView = ContentView(style: style.content)
    }
    super.init(frame: .zero)
    addSubviews()
    setUpConstraints()
    applyStyle()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Style: Hashable {
    init(content: ContentView.Style, card: CardStyle) {
      self.content = content
      self.card = card
    }

    init(card: CardStyle) where ContentView.Style == Never {
      self.card = card
    }

    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var content: ContentView.Style!
    fileprivate var card: CardStyle
  }

  struct CardStyle: Hashable {
    var cornerRadius: CGFloat = 10
    var layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    var cardBackgroundColor = UIColor.white
    var borderColor = UIColor.lightGray
    var borderWidth: CGFloat = 1
    var shadowColor = UIColor.black
    var shadowOffset = CGSize(width: 0, height: 2)
    var shadowRadius: CGFloat = 4
    var shadowOpacity: Float = 0.2
  }

  let contentView: ContentView

  func setContent(_ content: ContentView.Content, animated: Bool) {
    contentView.setContent(content, animated: animated)
  }

  // MARK: Private

  private let style: CardStyle

  private lazy var contentContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = true
    view.layer.cornerRadius = style.cornerRadius
    view.backgroundColor = style.cardBackgroundColor
    view.layer.borderWidth = style.borderWidth
    view.layer.borderColor = style.borderColor.cgColor
    return view
  }()

  private lazy var shadow: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.clipsToBounds = false
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = style.cornerRadius
    view.layer.shadowColor = style.shadowColor.cgColor
    view.layer.shadowOffset = style.shadowOffset
    view.layer.shadowOpacity = style.shadowOpacity
    view.layer.shadowRadius = style.shadowRadius
    return view
  }()

  private func addSubviews() {
    addSubview(shadow)
    contentContainer.addSubview(contentView)
    addSubview(contentContainer)
  }

  private func setUpConstraints() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      shadow.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      shadow.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      shadow.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      shadow.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
      contentView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
      contentView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
      contentContainer.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      contentContainer.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      contentContainer.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      contentContainer.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
    ])
  }

  private func applyStyle() {
    layoutMargins = style.layoutMargins
  }

}

// MARK: - UIEdgeInsets + Hashable

extension UIEdgeInsets: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(left)
    hasher.combine(right)
    hasher.combine(top)
    hasher.combine(bottom)
  }
}

// MARK: - CGSize + Hashable

extension CGSize: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(height)
    hasher.combine(width)
  }
}
