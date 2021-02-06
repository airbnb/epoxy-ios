// Created by matthew_cheok on 2/4/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - SelectableStackView

/// A stack of arbitrary bar views that can handle user selection.
public final class SelectableStackView: BarStackView, EpoxyableView {

  // MARK: Lifecycle

  /// - Parameters:
  ///   - style: The style to be used.
  required public init(style: Style) {
    self.style = style
    super.init(zOrder: .topToBottom)
  }

  // MARK: Public

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard let location = touches.first?.location(in: self) else { return }

    for wrapper in wrappers {
      guard let converted = wrapper.view?.convert(location, from: self) else { continue }
      if wrapper.view?.point(inside: converted, with: event) == true {
        selectedWrapper = wrapper
        break
      }
    }

    updateHighlighting()
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)

    /// TODO: Potentially suppport highlighting another bar that's currently beneath the touch
    /// (in the same style as `UIAlertController.Style.actionsheet`.)
    /// This would involve iterating through the wrappers to find the one contains the current point.

    guard
      let wrapper = selectedWrapper,
      let location = touches.first?.location(in: self),
      let converted = wrapper.view?.convert(location, from: self)
    else { return }

    if wrapper.view?.point(inside: converted, with: event) == false {
      selectedWrapper = nil
      updateHighlighting()
    }
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    selectedWrapper?.handleSelection(animated: false)
    selectedWrapper = nil
    updateHighlighting()
  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)

    selectedWrapper = nil
    updateHighlighting()
  }

  // MARK: Private

  /// The style to be used.
  private let style: Style

  /// The wrapper of the model being selected.
  private var selectedWrapper: BarWrapperView?

  /// Update the background of wrappers according to the current selection.
  private func updateHighlighting() {
    for wrapper in wrappers {
      wrapper.view?.backgroundColor = (selectedWrapper === wrapper)
        ? style.selectedBackgroundColor
        : nil
    }
  }
}

// MARK: - StyledView

extension SelectableStackView {

  /// The style to be used.
  public struct Style: Hashable {

    /// The selected background color to apply.
    var selectedBackgroundColor: UIColor?

    public init(selectedBackgroundColor: UIColor?) {
      self.selectedBackgroundColor = selectedBackgroundColor
    }
  }
}

// MARK: ContentConfigurableView

extension SelectableStackView {

  /// The content of the stack view.
  public struct Content: Equatable {

    /// The bar models to be rendered.
    public let models: [BarModeling]

    /// - Parameters:
    ///   - models: The bar models to be rendered.
    public init(models: [BarModeling]) {
      self.models = models
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
      // The content should never be equal since we need the `models`'s behavior to be updated on
      // every content change.
      false
    }
  }

  /// Update the content of the stack view.
  public func setContent(_ content: Content, animated: Bool) {
    setBars(content.models, animated: animated)
  }
}
