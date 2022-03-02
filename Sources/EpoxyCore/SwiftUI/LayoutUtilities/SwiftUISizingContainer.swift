// Created by Bryn Bodayle on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUISizingContainerConfiguration

/// The configuration provided to a `SwiftUISizingContainer`.
public struct SwiftUISizingContainerConfiguration {

  // MARK: Lifecycle

  public init(
    estimate: SwiftUISizingContainerContentSize = .defaultEstimatedSize,
    strategy: SwiftUIMeasurementContainerStrategy = .intrinsicHeightBoundsWidth,
    storage: SwiftUISizingContainerStorage = .init())
  {
    self.estimate = estimate
    self.strategy = strategy
    self.storage = storage
  }

  // MARK: Public

  /// An estimated size used as a placeholder ideal size until `UIView` measurement is able to
  /// occur.
  ///
  /// Pass `nil` for either `width` or `height` if this container is only used for reading the
  /// proposed size and an ideal size will never be provided.
  public var estimate: SwiftUISizingContainerContentSize

  /// The measurement strategy of a `SwiftUIMeasurementContainer`.
  ///
  /// Defaults to `.intrinsicHeightBoundsWidth`.
  public var strategy: SwiftUIMeasurementContainerStrategy

  /// The storage used for maintaining the ideal size of a `SwiftUISizingContainer`.
  ///
  /// Available to be passed into a `SwiftUISizingContainer` since there are configurations where
  /// `StateObject`s are deallocated when offscreen (e.g. deeply nested views within a
  /// `LazyVStack`), and hoisting the sizing storage to the top-level content of the `ForEach` can
  /// mitigate this issue.
  public var storage: SwiftUISizingContainerStorage
}

// MARK: - SwiftUISizingContainer

/// A container which reads the proposed SwiftUI layout size and passes it via a
/// ``SwiftUISizingContext`` to its `Content`, which then dictates the ideal size of this view by
/// updating the context's `idealSize`.
///
/// - SeeAlso: ``SwiftUIMeasurementContainer``
public struct SwiftUISizingContainer<Content: View>: View {

  // MARK: Lifecycle

  /// Constructs a `SwiftUISizingContainer` view.
  ///
  /// - Parameters:
  ///   - configuration: The configuration that includes an estimated size, measurement strategy,
  ///     and ideal size storage.
  ///   - content: The view content rendered using a `SwiftUISizingContext`, typically returning a
  ///     `SwiftUIMeasurementContainer` wrapping a `UIView`.
  public init(
    configuration: SwiftUISizingContainerConfiguration = .init(),
    content: @escaping (SwiftUISizingContext) -> Content)
  {
    estimate = configuration.estimate
    strategy = configuration.strategy
    storage = configuration.storage
    self.content = content
  }

  // MARK: Public

  public var body: some View {
    // Use the estimated size if the ideal size has not yet been computed.
    let size = storage.ideal ?? estimate

    GeometryReader { proxy in
      content(.init(strategy: strategy, proposedSize: proxy.size, idealSize: $storage.ideal))
    }
    // Pass the ideal size as the min/max to ensure this view doesn't get stretched/compressed.
    .frame(
      minWidth: size.width,
      idealWidth: size.width,
      maxWidth: size.width,
      minHeight: size.height,
      idealHeight: size.height,
      maxHeight: size.height)
  }

  // MARK: Private

  private let content: (SwiftUISizingContext) -> Content
  private let estimate: SwiftUISizingContainerContentSize
  private let strategy: SwiftUIMeasurementContainerStrategy
  @ObservedObject private var storage: SwiftUISizingContainerStorage
}

// MARK: - SwiftUISizingContainerContentSize

public struct SwiftUISizingContainerContentSize {

  // MARK: Lifecycle

  public init(width: CGFloat? = nil, height: CGFloat? = nil) {
    self.width = width
    self.height = height
  }

  public init(_ size: CGSize) {
    width = size.width
    height = size.height
  }

  // MARK: Public

  /// The default estimated size used as a placeholder ideal size until `UIView` measurement is able
  /// to occur.
  public static var defaultEstimatedSize: SwiftUISizingContainerContentSize {
    .init(width: 375, height: 150)
  }

  /// A nil `height` and `width`, indicating content with no intrinsic height or width, or no
  /// estimated size.
  public static var none: SwiftUISizingContainerContentSize {
    .init(width: nil, height: nil)
  }

  /// The width of the content, else `nil` if the content has no intrinsic width.
  public var width: CGFloat?

  /// The height of the content, else `nil` if the content has no intrinsic height.
  public var height: CGFloat?
}

// MARK: - SwiftUISizingContainerStorage

/// The storage used for maintaining the ideal size of a `SwiftUISizingContainer`.
///
/// Available to be passed into a `SwiftUISizingContainer` since there are configurations where
/// `StateObject`s are deallocated when offscreen (e.g. deeply nested views within a `LazyVStack`),
/// and hosting the sizing storage to the top-level `ForEach` can avoid this.
public final class SwiftUISizingContainerStorage: ObservableObject {

  // MARK: Lifecycle

  public init() {}

  // MARK: Fileprivate

  /// The ideal size computed by the `SwiftUIMeasurementContainer`, else `nil` if not yet
  /// determined.
  @Published fileprivate var ideal: SwiftUISizingContainerContentSize?
}

// MARK: - SwiftUISizingContext

/// The context available to the `Content` of a `SwiftUISizingContainer`, used communicate the
/// proposed size to the content and the ideal size back to the container.
public struct SwiftUISizingContext {

  // MARK: Lifecycle

  public init(
    strategy: SwiftUIMeasurementContainerStrategy,
    proposedSize: CGSize,
    idealSize: Binding<SwiftUISizingContainerContentSize?>)
  {
    self.strategy = strategy
    self.proposedSize = proposedSize
    _idealSize = idealSize
  }

  // MARK: Public

  /// The measurement strategy of the `SwiftUIMeasurementContainer` content.
  public var strategy: SwiftUIMeasurementContainerStrategy

  /// The proposed layout size for the view.
  public var proposedSize: CGSize

  /// The ideal or intrinsic size for the content view; updated after its measurement, else `nil`
  /// if it has not yet been determined.
  @Binding public var idealSize: SwiftUISizingContainerContentSize?
}
