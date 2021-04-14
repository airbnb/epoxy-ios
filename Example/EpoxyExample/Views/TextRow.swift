// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - TextRow

final class TextRow: UIView, EpoxyableView {

  // MARK: Lifecycle

  init(style: Style) {
    self.style = style
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  enum Style {
    case small, large
  }

  struct Content: Equatable {
    var title: String?
    var body: String?
  }

  func setContent(_ content: Content, animated: Bool) {
    let titleFont: UIFont
    let bodyFont: UIFont

    switch style {
    case .large:
      titleFont = UIFont.preferredFont(forTextStyle: .headline)
      bodyFont = UIFont.preferredFont(forTextStyle: .body)
    case .small:
      titleFont = UIFont.preferredFont(forTextStyle: .body)
      bodyFont = UIFont.preferredFont(forTextStyle: .caption1)
    }

    group.setItems {
      if let title = content.title {
        labelItem(
          dataID: DataID.title,
          text: title,
          font: titleFont)
          .adjustsFontForContentSizeCategory(true)
          .textColor(UIColor.label)
      }
      if let body = content.body {
        labelItem(
          dataID: DataID.body,
          text: body,
          font: bodyFont)
          .adjustsFontForContentSizeCategory(true)
          .numberOfLines(0)
          .textColor(UIColor.secondaryLabel)
      }
    }
  }

  // MARK: Private

  private enum DataID {
    case title
    case body
  }

  private let style: Style
  private let group = VGroup(spacing: 8)

  private func labelItem(
    dataID: AnyHashable,
    text: String,
    font: UIFont)
    -> GroupItem<UILabel>
  {
    GroupItem<UILabel>(
      dataID: dataID,
      params: font,
      content: text,
      make: { font in
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        return label
      },
      setContent: { context, content in
        context.constrainable.text = content
      })
  }
}

// MARK: SelectableView

extension TextRow: SelectableView {
  func didSelect() {
    // Handle this row being selected, e.g. to trigger haptics:
    UISelectionFeedbackGenerator().selectionChanged()
  }
}

// MARK: HighlightableView

extension TextRow: HighlightableView {
  func didHighlight(_ isHighlighted: Bool) {
    UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
      self.transform = isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
    }
  }
}

// MARK: DisplayRespondingView

extension TextRow: DisplayRespondingView {
  func didDisplay(_ isDisplayed: Bool) {
    // Handle this row being displayed.
  }
}
