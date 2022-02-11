// Created by Bryn Bodayle on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUISizingContainer

/// A container which reads the proposed SwiftUI layout and passes it a `SwiftUISizingContext`. This
/// stores ideal size as state in order to configure the view layout as the ideal size is updated
/// via the `SwiftUISizingContext`.
public struct SwiftUISizingContainer<Content: View>: View {

  // MARK: Lifecycle

  /// Constructs a `SwiftUISizingContainer` view
  /// - Parameters:
  ///   - estimatedSize: An estimated size used as a placeholder ideal size until view measurement
  ///     occurs. Pass `nil` for this parameter if this container is only used for reading the
  ///     proposed size and an ideal size will never be provided.
  ///   - content: The view content to wrap and provide a `SwiftUISizingContext` to.
  public init(
    estimatedWidth: CGFloat? = 375,
    estimatedHeight: CGFloat? = 150,
    content: @escaping (SwiftUISizingContext) -> Content)
  {
    self.content = content
    estimatedSize = (width: estimatedWidth, height: estimatedHeight)
  }

  // MARK: Public

  public var body: some View {
    GeometryReader { proxy in
      content(.init(proposedSize: proxy.size, idealSize: $idealSize.value))
    }
    // Pass the ideal size as the max size to ensure this view doesn't get stretched.
    .frame(
      idealWidth: idealSize.value.width ?? estimatedSize.width,
      maxWidth: idealSize.value.width,
      idealHeight: idealSize.value.height ?? estimatedSize.height,
      maxHeight: idealSize.value.height)
  }

  // MARK: Private

  private final class IdealSize: ObservableObject {
    @Published var value: (width: CGFloat?, height: CGFloat?)
  }

  private let content: (SwiftUISizingContext) -> Content
  private let estimatedSize: (width: CGFloat?, height: CGFloat?)
  @StateObject private var idealSize = IdealSize()
}

// MARK: - SwiftUISizingContext

/// The context available to the `Content` of a `SwiftUISizingContainer`, used communicate the ideal
/// size to the container.
public struct SwiftUISizingContext {

  // MARK: Lifecycle

  public init(proposedSize: CGSize, idealSize: Binding<(width: CGFloat?, height: CGFloat?)>) {
    self.proposedSize = proposedSize
    _idealSize = idealSize
  }

  // MARK: Public

  /// The proposed layout size for the view
  public let proposedSize: CGSize

  /// The ideal or intrinsic size for the content view; updated after its measurement.
  @Binding public var idealSize: (width: CGFloat?, height: CGFloat?)
}
