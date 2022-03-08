// Created by Bryn Bodayle on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUISizingContainerConfiguration

/// The configuration provided to a `SwiftUISizingContainer`.
public struct SwiftUISizingContainerConfiguration {

  // MARK: Lifecycle

  public init(
    estimate: SwiftUISizingContainerContentSize,
    strategy: SwiftUIMeasurementContainerStrategy,
    storage: SwiftUISizingContainerStorage? = nil)
  {
    self.estimate = estimate
    self.strategy = strategy
    self.storage = storage
  }

  // MARK: Public

  /// The `content` view is sized to fill the bounds offered by its parent.
  public static var boundsSize: Self {
    // No estimated size is needed in the case of a bounds-sized component it is always sized to fit
    // the area offered by its parent.
    .init(estimate: .none, strategy: .boundsSize)
  }

  /// The `content` view is sized with its intrinsic height and expands horizontally to fill the
  /// bounds offered by its parent
  ///
  /// This is the default configuration.
  public static var intrinsicHeightBoundsWidth: Self {
    .init(estimate: .defaultEstimatedSize, strategy: .intrinsicHeightBoundsWidth)
  }

  /// The `content` view is sized with its intrinsic width and expands vertically to fill the bounds
  /// offered by its parent.
  public static var intrinsicWidthBoundsHeight: Self {
    .init(estimate: .defaultEstimatedSize, strategy: .intrinsicWidthBoundsHeight)
  }

  /// The `content` view is sized to its intrinsic width and height.
  public static var intrinsicSize: Self {
    // No estimated size is needed in the case of intrinsically sized components since they don't
    // require a two-phase layout with an estimated size.
    .init(estimate: .none, strategy: .intrinsicSize)
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

  /// The storage used for maintaining the ideal size of a `SwiftUISizingContainer`, else nil if
  /// it should be allocated lazily.
  ///
  /// Available to be passed into a `SwiftUISizingContainer` since there are configurations where
  /// `StateObject`s are deallocated when offscreen (e.g. deeply nested views within a
  /// `LazyVStack`), and hoisting the sizing storage to the top-level content of the `ForEach` can
  /// mitigate this issue.
  public var storage: SwiftUISizingContainerStorage?
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
    configuration: SwiftUISizingContainerConfiguration,
    content: @escaping (SwiftUISizingContext) -> Content)
  {
    self.configuration = configuration
    self.content = content
  }

  // MARK: Public

  public var body: some View {
    if #available(iOS 14, *) {
      StorageView14(storage: configuration.storage, content: content(ideal:))
    } else {
      StorageView13(storage: configuration.storage, content: content(ideal:))
    }
  }

  // MARK: Private

  private var content: (SwiftUISizingContext) -> Content
  private var configuration: SwiftUISizingContainerConfiguration

  private func content(ideal: Binding<SwiftUISizingContainerContentSize?>) -> some View {
    // Use the estimated size if the ideal size has not yet been computed.
    let size = ideal.wrappedValue ?? configuration.estimate

    return GeometryReader { proxy in
      content(.init(strategy: configuration.strategy, proposedSize: proxy.size, idealSize: ideal))
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
}

// MARK: - SwiftUISizingContainerContentSize

public struct SwiftUISizingContainerContentSize: Equatable {

  // MARK: Lifecycle

  public init(width: CGFloat? = nil, height: CGFloat? = nil) {
    self.width = width
    self.height = height
  }

  public init(_ size: CGSize) {
    width = (size.width == UIView.noIntrinsicMetric) ? nil : size.width
    height = (size.height == UIView.noIntrinsicMetric) ? nil : size.height
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

// MARK: - SwiftUISizingContainer

extension SwiftUISizingContainer where Content: UIViewConfiguringSwiftUIView {
  /// Configures the `View` contents of this sizing container whenever it is updated via
  /// `UIViewRepresentable.updateUIView`.
  ///
  /// You can use this closure to perform additional configuration of the view beyond the
  /// configuration specified at initialization or in its contents, behaviors, or style.
  public func configure(_ configure: @escaping (Content.View) -> Void) -> Self {
    var copy = self
    copy.content = { [content] context in
      content(context).configure(configure)
    }
    return copy
  }

  /// Configures the `View` contents of this sizing container whenever it is updated via
  /// `UIViewRepresentable.updateUIView`.
  ///
  /// You can use this closure to perform additional configuration of the view beyond the
  /// configuration specified at initialization or in its contents, behaviors, or style.
  public func configurations(_ configurations: [(Content.View) -> Void]) -> Self {
    var copy = self
    copy.content = { [content] context in
      content(context).configurations(configurations)
    }
    return copy
  }
}

// MARK: - StorageView14

/// Hosts the `SwiftUISizingContainerStorage` state on iOS 14+ where `StateObject` is available.
@available(iOS 14, *)
private struct StorageView14<Content: View>: View {
  init(
    storage: SwiftUISizingContainerStorage?,
    content: @escaping (Binding<SwiftUISizingContainerContentSize?>) -> Content)
  {
    _storage = .init(wrappedValue: storage ?? .init())
    self.content = content
  }

  var body: some View {
    content($storage.ideal)
  }

  @StateObject private var storage: SwiftUISizingContainerStorage
  private var content: (Binding<SwiftUISizingContainerContentSize?>) -> Content
}

// MARK: - StorageView13

/// Hosts the `SwiftUISizingContainerStorage` state on iOS 13 where `StateObject` is not available.
private struct StorageView13<Content: View>: View {
  init(
    storage: SwiftUISizingContainerStorage?,
    content: @escaping (Binding<SwiftUISizingContainerContentSize?>) -> Content)
  {
    _storage = .init(wrappedValue: storage ?? .init())
    self.content = content
  }

  var body: some View {
    content($storage.ideal)
  }

  @ObservedObject private var storage: SwiftUISizingContainerStorage
  private var content: (Binding<SwiftUISizingContainerContentSize?>) -> Content
}
