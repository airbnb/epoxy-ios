// Created by Bryn Bodayle on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUIMeasurementContainer

/// A view that has an `intrinsicContentSize` of the `uiView`'s `systemLayoutSizeFitting(…)` and
/// supports double layout pass sizing and content size category changes.
///
/// This container view uses an injected proposed width to measure the view and return its ideal
/// height through the `SwiftUISizingContext` binding.
///
/// - SeeAlso: ``SwiftUISizingContainer``
public final class SwiftUIMeasurementContainer<SwiftUIView, UIViewType: UIView>: UIView {

  // MARK: Lifecycle

  public init(view: SwiftUIView, uiView: UIViewType, context: SwiftUISizingContext) {
    self.view = view
    self.uiView = uiView
    self.context = context
    // On the first layout, use the `proposedSize` to measure with a reasonable first attempt, as
    // passing zero results in unusable sizes and also upsets SwiftUI.
    super.init(frame: .init(origin: .zero, size: context.proposedSize))

    addSubview(uiView)
    setUpConstraints()
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var view: SwiftUIView

  public var uiView: UIViewType {
    didSet { updateView(from: oldValue) }
  }

  public override var intrinsicContentSize: CGSize {
    if let size = latestMeasuredSize {
      return size
    }

    return measureView().size
  }

  public override func invalidateIntrinsicContentSize() {
    latestMeasuredSize = nil
    super.invalidateIntrinsicContentSize()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    // We need to re-measure the view whenever the size of the bounds changes and the view is
    // sized to the bounds size, as the previous size will now be incorrect.
    if bounds.size != latestMeasurementBoundsSize, measureView().changed {
      super.invalidateIntrinsicContentSize()
    }
  }

  // MARK: Private

  private let context: SwiftUISizingContext

  /// The bounds size at the time of the latest measurement.
  ///
  /// Used to ensure we don't do extraneous measurements if the bounds haven't changed.
  private var latestMeasurementBoundsSize: CGSize?

  /// The most recently measured intrinsic content size of the `uiView`, else `nil` if it has not
  /// yet been measured.
  private var latestMeasuredSize: CGSize? = nil

  private func updateView(from oldValue: UIViewType) {
    guard uiView !== oldValue else { return }
    oldValue.removeFromSuperview()
    addSubview(uiView)
    setUpConstraints()
    setNeedsLayout()
  }

  private func setUpConstraints() {
    uiView.translatesAutoresizingMaskIntoConstraints = false

    let leading = uiView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let top = uiView.topAnchor.constraint(equalTo: topAnchor)
    let trailing = uiView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let bottom = uiView.bottomAnchor.constraint(equalTo: bottomAnchor)

    let almostRequiredPriority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)

    // Give a required constraint in the dimensions that are fixed to the bounds, otherwise almost
    // required.
    switch context.strategy {
    case .boundsSize:
      (trailing.priority, bottom.priority) = (.required, .required)
    case .intrinsicHeightBoundsWidth:
      (trailing.priority, bottom.priority) = (.required, almostRequiredPriority)
    case .intrinsicWidthBoundsHeight:
      (trailing.priority, bottom.priority) = (almostRequiredPriority, .required)
    case .intrinsicSize:
      (trailing.priority, bottom.priority) = (almostRequiredPriority, almostRequiredPriority)
    }

    NSLayoutConstraint.activate([leading, top, trailing, bottom])
  }

  /// Measures the `uiView`, returning the resulting size and whether it changed from the previously
  /// measured size stored in `latestMeasuredSize`.
  @discardableResult
  private func measureView() -> (size: CGSize, changed: Bool) {
    latestMeasurementBoundsSize = bounds.size

    var measuredSize: CGSize
    switch context.strategy {
    case .boundsSize:
      measuredSize = .init(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)

    case .intrinsicHeightBoundsWidth:
      let targetSize = CGSize(
        width: bounds.width,
        height: UIView.layoutFittingCompressedSize.height)

      measuredSize = uiView.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel)

      measuredSize.width = UIView.noIntrinsicMetric

    case .intrinsicWidthBoundsHeight:
      let targetSize = CGSize(
        width: UIView.layoutFittingCompressedSize.width,
        height: bounds.height)

      measuredSize = uiView.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .required)

      measuredSize.height = UIView.noIntrinsicMetric

    case .intrinsicSize:
      measuredSize = uiView.systemLayoutSizeFitting(
        UIView.layoutFittingCompressedSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .fittingSizeLevel)

      // Once we've set the ideal size after the first measurement pass where we communicate the
      // ideal size up to the enclosing `SwiftUISizingContainer`:
      if context.idealSize != nil {
        // If the measured size exceeds the available width or height, set the measured size to
        // `noIntrinsicMetric` to ensure that the component can be compressed, otherwise it will
        // overflow beyond the proposed size.
        if
          measuredSize.width > bounds.width,
          latestMeasuredSize == nil || latestMeasuredSize?.width == UIView.noIntrinsicMetric
        {
          measuredSize.width = UIView.noIntrinsicMetric
        }
        if
          measuredSize.height > bounds.height,
          latestMeasuredSize == nil || latestMeasuredSize?.height == UIView.noIntrinsicMetric
        {
          measuredSize.height = UIView.noIntrinsicMetric
        }
      }
    }

    let changed = (latestMeasuredSize != measuredSize)
    if changed {
      latestMeasuredSize = measuredSize
      context.idealSize = .init(measuredSize)
    }

    return (size: measuredSize, changed: changed)
  }
}

// MARK: - SwiftUIMeasurementContainerStrategy

/// The measurement strategy of a `SwiftUIMeasurementContainer`.
public enum SwiftUIMeasurementContainerStrategy {
  /// The `uiView` is sized to fill the bounds offered by its parent.
  case boundsSize
  /// The `uiView` is sized with its intrinsic height and expands horizontally to fill the bounds
  /// offered by its parent.
  case intrinsicHeightBoundsWidth
  /// The `uiView` is sized with its intrinsic width and expands vertically to fill the bounds
  /// offered by its parent.
  case intrinsicWidthBoundsHeight
  /// The `uiView` is sized to its intrinsic width and height.
  case intrinsicSize
}
