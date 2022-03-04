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

  /// The `content` view is sized to fill the bounds offered by its parent.
  public static var boundsSize: Self {
    .init(strategy: .boundsSize)
  }

  /// The `content` view is sized with its intrinsic height and expands horizontally to fill the
  /// bounds offered by its parent
  ///
  /// This is the default configuration.
  public static var intrinsicHeightBoundsWidth: Self {
    .init()
  }

  /// The `content` view is sized with its intrinsic width and expands vertically to fill the bounds
  /// offered by its parent.
  public static var intrinsicWidthBoundsHeight: Self {
    .init(strategy: .intrinsicWidthBoundsHeight)
  }

  /// The `content` view is sized to its intrinsic width and height.
  public static var intrinsicSize: Self {
    .init(strategy: .intrinsicSize)
  }

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

    // Inlining this closure doesn't work as it won't compile as a view builder.
    let render: (GeometryProxy) -> Content = { proxy in
      var result = content(
        .init(strategy: strategy, proposedSize: proxy.size, idealSize: $storage.ideal))
      for configuration in configurations {
        configuration(&result)
      }
      return result
    }

    GeometryReader(content: render)
      // Pass the ideal size as the min/max to ensure this view doesn't get stretched/compressed.
      .frame(
        minWidth: size.width,
        idealWidth: size.width,
        maxWidth: size.width,
        minHeight: size.height,
        idealHeight: size.height,
        maxHeight: size.height)
  }

  // MARK: Internal

  var configurations = [(inout Content) -> Void]()

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

// MARK: - SwiftUISizingContainerContent

/// A protocol describing a SwiftUI `View` that can configure its `UIView` contents via an array of
/// `configuration` closures.
public protocol SwiftUISizingContainerContent: View {
  /// The `UIView` represented by this view.
  associatedtype View: UIView

  /// A mutable array of configuration closures that should each be invoked with the represented
  /// `UIView` whenever `updateUIView` is called in a `UIViewRepresentable`.
  var configurations: [(View) -> Void] { get set }
}

// MARK: - SwiftUISizingContainer

extension SwiftUISizingContainer where Content: SwiftUISizingContainerContent {
  /// Configures the `View` contents of this sizing container whenever it is updated via
  /// `UIViewRepresentable.updateUIView`.
  ///
  /// You can use this closure to perform additional configuration of the view beyond the
  /// configuration specified at initialization or in its contents, behaviors, or style.
  public func configure(_ configure: @escaping (Content.View) -> Void) -> Self {
    var copy = self
    copy.configurations.append { content in
      content.configurations.append(configure)
    }
    return copy
  }
}
