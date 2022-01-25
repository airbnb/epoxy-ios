// Created by Bryn Bodayle on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SizingContainer

/// A container which reads the proposed SwiftUI layout and passes it a `SizingContext`. This stores
/// ideal size as state in order to configure the view layout as the ideal size is updated via the
/// `SizingContext`.
public struct SizingContainer<Content: View>: View {

  // MARK: Lifecycle

  /// Constructs a `SizingContainer` view
  /// - Parameters:
  ///   - estimatedSize: An estimated size used as a placeholder ideal size until view measurement
  ///     occurs. Pass `nil` for this parameter if this container is only used for reading the
  ///     proposed size and an ideal size will never be provided.
  ///   - content: The view content to wrap and provide a `SizingContext` to.
  public init(
    estimatedSize: CGSize? = CGSize(width: 375, height: 150),
    content: @escaping (SizingContext) -> Content)
  {
    self.content = content
    self.estimatedSize = estimatedSize
  }

  // MARK: Public

  public var body: some View {
    GeometryReader { proxy in
      content(
        .init(
          proposedSize: proxy.size,
          idealWidth: $idealWidth,
          idealHeight: $idealHeight))
    }
    // Pass the ideal size as the max size to ensure this view doesn't get stretched.
    .frame(
      idealWidth: idealWidth ?? estimatedSize?.width,
      maxWidth: idealWidth,
      idealHeight: idealHeight ?? estimatedSize?.height,
      maxHeight: idealHeight)
  }

  // MARK: Private

  private let content: (SizingContext) -> Content
  private let estimatedSize: CGSize?
  @State private var idealWidth: CGFloat?
  @State private var idealHeight: CGFloat?
}

// MARK: - SizingContext

public struct SizingContext {

  // MARK: Lifecycle

  public init(proposedSize: CGSize, idealWidth: Binding<CGFloat?>, idealHeight: Binding<CGFloat?>) {
    self.proposedSize = proposedSize
    self.idealWidth = idealWidth
    self.idealHeight = idealHeight
  }

  // MARK: Public

  /// The proposed layout size for the view
  public let proposedSize: CGSize

  /// The ideal or intrinsic width for the view after measurement
  public var idealWidth: Binding<CGFloat?>

  /// The ideal or intrinsic height for the view after measurement
  public var idealHeight: Binding<CGFloat?>
}
