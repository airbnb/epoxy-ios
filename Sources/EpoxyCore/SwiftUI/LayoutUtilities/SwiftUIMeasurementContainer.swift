// Created by Bryn Bodayle on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUIMeasurementContainer

/// A view that has an `intrinsicContentSize` of the `view`'s `systemLayoutSizeFitting(…)` and
/// supports double layout pass sizing and content size category changes.
/// This container view uses an injected proposed width to measure the view and return its ideal
/// height through the `SwiftUISizingContext` binding.
public final class SwiftUIMeasurementContainer<SwiftUIView, UIViewType>: UIView
  where
  UIViewType: UIView
{

  // MARK: Lifecycle

  public init(
    view: SwiftUIView,
    uiView: UIViewType,
    context: SwiftUISizingContext,
    sizingBehavior: SwiftUIMeasurementContainerSizingBehavior)
  {
    self.view = view
    self.uiView = uiView
    self.context = context
    self.sizingBehavior = sizingBehavior
    super.init(frame: .zero)

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

    // We need to re-measure the view whenever the size of the bounds change, as the previous size
    // will be incorrect.
    if bounds.size != latestMeasurementBoundsSize {
      if measureView().changed {
        super.invalidateIntrinsicContentSize()
      }
    }
  }

  // MARK: Private

  private let context: SwiftUISizingContext

  private let sizingBehavior: SwiftUIMeasurementContainerSizingBehavior

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

    // These constraints won't be fulfilled when resizing, but it should be higher than any other
    // layout priorities.
    let constraintPriority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)

    let trailing = uiView.trailingAnchor.constraint(equalTo: trailingAnchor)
    trailing.priority = constraintPriority

    let bottom = uiView.bottomAnchor.constraint(equalTo: bottomAnchor)
    bottom.priority = constraintPriority

    NSLayoutConstraint.activate([leading, top, trailing, bottom])
  }

  /// Measures the `uiView`, returning the resulting size and whether it changed from the previously
  /// measured size stored it in `latestMeasuredSize`.
  @discardableResult
  private func measureView() -> (size: CGSize, changed: Bool) {
    // On the first layout, use the `initialSize` to measure with a reasonable first attempt, as
    // passing zero results in unusable sizes and also upsets SwiftUI.
    let measurementBounds = bounds.size == .zero ? context.proposedSize : bounds.size
    latestMeasurementBoundsSize = measurementBounds

    let targetSize, measuredSize: CGSize
    switch sizingBehavior {
    case .intrinsicHeightBoundsWidth:
      targetSize = CGSize(
        width: measurementBounds.width,
        height: UIViewType.layoutFittingCompressedSize.height)

      let fittingSize = uiView.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .defaultHigh,
        verticalFittingPriority: .fittingSizeLevel)

      measuredSize = CGSize(width: UIView.noIntrinsicMetric, height: fittingSize.height)

      context.idealSize = (width: nil, height: measuredSize.height)

    case .intrinsicWidthBoundsHeight:
      targetSize = CGSize(
        width: UIViewType.layoutFittingCompressedSize.width,
        height: measurementBounds.height)

      let fittingSize = uiView.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .defaultHigh)

      measuredSize = CGSize(width: fittingSize.width, height: UIView.noIntrinsicMetric)

      context.idealSize = (width: measuredSize.width, height: measuredSize.height)

    case .intrinsicSize:
      targetSize = CGSize(
        width: UIViewType.layoutFittingCompressedSize.height,
        height: UIViewType.layoutFittingCompressedSize.height)

      measuredSize = uiView.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .fittingSizeLevel)

      context.idealSize = (width: measuredSize.width, height: measuredSize.height)
    }

    let changed = (latestMeasuredSize != measuredSize)
    if changed {
      latestMeasuredSize = measuredSize
    }

    return (size: measuredSize, changed: changed)
  }
}

// MARK: - SwiftUIMeasurementContainerSizingBehavior

/// The sizing behavior of a `SwiftUIMeasurementContainer`.
public enum SwiftUIMeasurementContainerSizingBehavior {
  /// The `uiView` is sized with its intrinsic height and expands horizontally to fill the bounds
  /// offered by its parent.
  case intrinsicHeightBoundsWidth
  /// The `uiView` is sized with its intrinsic width and expands vertically to fill the bounds
  /// offered by its parent.
  case intrinsicWidthBoundsHeight
  /// The `uiView` is sized to with its intrinsic width and height.
  case intrinsicSize
}
