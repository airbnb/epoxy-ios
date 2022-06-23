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
/// - SeeAlso: ``MeasuringUIViewRepresentable``
public final class SwiftUIMeasurementContainer<SwiftUIView, UIViewType: UIView>: UIView {

  // MARK: Lifecycle

  public init(view: SwiftUIView, uiView: UIViewType, strategy: SwiftUIMeasurementContainerStrategy) {
    self.view = view
    self.uiView = uiView
    self.strategy = strategy

    // On iOS 15 and below, passing zero can result in a constraint failure the first time a view
    // is displayed, but the system gracefully recovers afterwards. On iOS 16, it's fine to pass
    // zero.
    let initialSize: CGSize
    if #available(iOS 16, *) {
      initialSize = .zero
    } else {
      initialSize = .init(width: 375, height: 150)
    }
    super.init(frame: .init(origin: .zero, size: initialSize))

    addSubview(uiView)
    setUpConstraints()
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// The most recently updated SwiftUI `View` that constructed this measurement container, used to
  /// perform comparisons with the previous fields, if needed.
  ///
  /// Has no side-effects when updated; purely available as a convenience.
  public var view: SwiftUIView

  /// The  most recently measured fitting size of the `uiView` that fits within the current
  /// `proposedSize`, else `zero` if it has not yet been measured.
  ///
  /// Contains `proposedSize`/`bounds.size` fallbacks for dimensions with no intrinsic size, as
  /// compared to `intrinsicContentSize` which has `UIView.noIntrinsicMetric` fields in the case of
  /// no intrinsic size.
  public private(set) var measuredFittingSize = CGSize.zero

  /// The `UIView` that's being measured by this container.
  public var uiView: UIViewType {
    didSet {
      guard uiView !== oldValue else { return }
      oldValue.removeFromSuperview()
      addSubview(uiView)
      setUpConstraints()
      measureView()
    }
  }

  /// The proposed size at the time of the latest measurement.
  ///
  /// Has a side-effect of updating the measuredIntrinsicContentSize if it's changed.
  public var proposedSize = CGSize.noIntrinsicMetric {
    didSet {
      guard oldValue != proposedSize else { return }
      measureView()
    }
  }

  public var strategy: SwiftUIMeasurementContainerStrategy {
    didSet {
      guard oldValue != strategy else { return }
      // We need to first re-configure the constraints since they depend on the strategy.
      setUpConstraints()
      // Then, we need to re-measure the view.
      measureView()
    }
  }

  public override var intrinsicContentSize: CGSize {
    _intrinsicContentSize
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    // We need to re-measure the view whenever the size of the bounds changes, as the previous size
    // will now be incorrect.
    if latestMeasurementBoundsSize != nil, bounds.size != latestMeasurementBoundsSize {
      // This will trigger SwiftUI to re-measure the view.
      invalidateIntrinsicContentSize()
    }
  }

  // MARK: Private

  /// The most recently measured intrinsic content size of the `uiView`, else `noIntrinsicMetric` if
  /// it has not yet been measured.
  ///
  /// Contains `UIView.noIntrinsicMetric` fallbacks for dimensions with no intrinsic size,
  /// as compared to `measuredFittingSize` which has `proposedSize`/`bounds.size` fallbacks.
  private var _intrinsicContentSize = CGSize.noIntrinsicMetric

  /// The bounds size at the time of the latest measurement.
  private var latestMeasurementBoundsSize: CGSize?

  /// The most recently updated set of constraints constraining `uiView` to `self`.
  private var uiViewConstraints = [NSLayoutConstraint]()

  private func setUpConstraints() {
    uiView.translatesAutoresizingMaskIntoConstraints = false

    let leading = uiView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let top = uiView.topAnchor.constraint(equalTo: topAnchor)
    let trailing = uiView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let bottom = uiView.bottomAnchor.constraint(equalTo: bottomAnchor)

    // Give a required constraint in the dimensions that are fixed to the bounds, otherwise almost
    // required.
    switch strategy {
    case .proposed:
      (trailing.priority, bottom.priority) = (.required, .required)
    case .intrinsicHeightProposedWidth:
      (trailing.priority, bottom.priority) = (.required, .almostRequired)
    case .intrinsicWidthProposedHeight:
      (trailing.priority, bottom.priority) = (.almostRequired, .required)
    case .intrinsic:
      (trailing.priority, bottom.priority) = (.almostRequired, .almostRequired)
    }

    NSLayoutConstraint.deactivate(uiViewConstraints)
    uiViewConstraints = [leading, top, trailing, bottom]
    NSLayoutConstraint.activate(uiViewConstraints)
  }

  /// Measures the `uiView`, storing the resulting size in `measuredIntrinsicContentSize`.
  private func measureView() {
    latestMeasurementBoundsSize = bounds.size

    var measuredSize: CGSize
    let proposedSizeElseBounds = proposedSize.replacingNoIntrinsicMetric(with: bounds.size)

    switch strategy {
    case .proposed:
      measuredSize = .noIntrinsicMetric

    case .intrinsicHeightProposedWidth:
      let targetSize = CGSize(
        width: proposedSizeElseBounds.width,
        height: UIView.layoutFittingCompressedSize.height)

      measuredSize = uiView.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .almostRequired,
        verticalFittingPriority: .fittingSizeLevel)

      measuredSize.width = UIView.noIntrinsicMetric

    case .intrinsicWidthProposedHeight:
      let targetSize = CGSize(
        width: UIView.layoutFittingCompressedSize.width,
        height: proposedSizeElseBounds.height)

      measuredSize = uiView.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .almostRequired)

      measuredSize.height = UIView.noIntrinsicMetric

    case .intrinsic:
      measuredSize = uiView.systemLayoutSizeFitting(
        UIView.layoutFittingCompressedSize,
        withHorizontalFittingPriority: .fittingSizeLevel,
        verticalFittingPriority: .fittingSizeLevel)

      // If the measured size exceeds the available width or height, set the measured size to
      // `noIntrinsicMetric` to ensure that the component can be compressed, otherwise it will
      // overflow beyond the proposed size.
      if measuredSize.width > proposedSizeElseBounds.width {
        measuredSize.width = UIView.noIntrinsicMetric
      }
      if measuredSize.height > proposedSizeElseBounds.height {
        measuredSize.height = UIView.noIntrinsicMetric
      }
    }

    _intrinsicContentSize = measuredSize
    measuredFittingSize = measuredSize.replacingNoIntrinsicMetric(with: proposedSizeElseBounds)
  }
}

// MARK: - SwiftUIMeasurementContainerStrategy

/// The measurement strategy of a `SwiftUIMeasurementContainer`.
public enum SwiftUIMeasurementContainerStrategy {
  /// The `uiView` is sized to fill the area proposed by its parent.
  ///
  /// Typically used for views that should expand greedily in both axes, e.g. a background view.
  case proposed

  /// The `uiView` is sized with its intrinsic height and expands horizontally to fill the width
  /// proposed by its parent.
  ///
  /// Typically used for views that have a height that's a function of their width, e.g. a row with
  /// text that can wrap to multiple lines.
  case intrinsicHeightProposedWidth

  /// The `uiView` is sized with its intrinsic width and expands vertically to fill the height
  /// proposed by its parent.
  ///
  /// Typically used for views that are free to grow vertically but have a fixed width, e.g. a view
  /// in a horizontal carousel.
  case intrinsicWidthProposedHeight

  /// The `uiView` is sized to its intrinsic width and height.
  ///
  /// Typically used for components with a specific intrinsic size in both axes, e.g. controls or
  /// inputs.
  case intrinsic
}

// MARK: - UILayoutPriority

extension UILayoutPriority {
  /// An "almost required" constraint, useful for creating near-required constraints that don't
  /// error when unable to be satisfied.
  @nonobjc
  fileprivate static var almostRequired: UILayoutPriority { .init(rawValue: required.rawValue - 1) }
}

// MARK: - CGSize

extension CGSize {
  /// A `CGSize` with `noIntrinsicMetric` for both its width and height.
  fileprivate static var noIntrinsicMetric: CGSize {
    .init(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
  }

  /// Returns a `CGSize` with its width and/or height replaced with the corresponding field of the
  /// provided `fallback` size if they are `UIView.noIntrinsicMetric`.
  fileprivate func replacingNoIntrinsicMetric(with fallback: CGSize) -> CGSize {
    .init(
      width: width == UIView.noIntrinsicMetric ? fallback.width : width,
      height: height == UIView.noIntrinsicMetric ? fallback.height : height)
  }
}
