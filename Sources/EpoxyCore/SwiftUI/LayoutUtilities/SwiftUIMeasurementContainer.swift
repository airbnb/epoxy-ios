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

  public init(view: SwiftUIView, uiView: UIViewType, context: SwiftUISizingContext) {
    self.view = view
    self.uiView = uiView
    self.context = context
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

    return measureView()
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
      measureView()
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

    // These constraints won't be fulfilled when resizing, but it should be higher than any other
    // layout priorities.
    let constraintPriority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)

    let trailing = uiView.trailingAnchor.constraint(equalTo: trailingAnchor)
    trailing.priority = constraintPriority

    let bottom = uiView.bottomAnchor.constraint(equalTo: bottomAnchor)
    bottom.priority = constraintPriority

    NSLayoutConstraint.activate([leading, top, trailing, bottom])
  }

  /// Measures the `uiView`, returning the resulting size and storing it in `latestMeasuredSize`.
  @discardableResult
  private func measureView() -> CGSize {
    // On the first layout, use the `initialSize` to measure with a reasonable first attempt, as
    // passing zero results in unusable sizes and also upsets SwiftUI.
    let measurementBounds = bounds.size == .zero ? context.proposedSize : bounds.size
    latestMeasurementBoundsSize = measurementBounds

    let targetSize = CGSize(
      width: measurementBounds.width,
      height: UIViewType.layoutFittingCompressedSize.height)

    let fittingSize = uiView.systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .defaultHigh,
      verticalFittingPriority: .fittingSizeLevel)

    let measuredSize = CGSize(width: UIView.noIntrinsicMetric, height: fittingSize.height)

    // We need to update the ideal size async otherwise we'll get the "Modifying state during view
    // update, which will cause undefined behavior" runtime warning as the view's intrinsic content
    // size is queried during the view update phase.
    DispatchQueue.main.async { [idealHeight = context.idealHeight] in
      idealHeight.wrappedValue = measuredSize.height
    }

    if latestMeasuredSize != measuredSize {
      latestMeasuredSize = measuredSize
      // We call super directly here so we don't keep measuring in an infinite loop
      super.invalidateIntrinsicContentSize()
    }

    return measuredSize
  }
}
