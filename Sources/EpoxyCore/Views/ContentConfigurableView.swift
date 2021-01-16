//  Created by Laura Skelton on 5/30/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

// MARK: - ContentConfigurableView

/// A view that can be configured with a `Content` instance that contains the view's `Equatable`
/// properties that can be updated on existing view instances, e.g. text `String`s or image `URL`s.
///
/// For performance, it is generally expected that `Content` is only set when it is not equal to the
/// previous `Content` instance that has been set on a view instance. As a further optimization,
/// this view can guard updates on the equality of each property of the `Content` against the
/// current property value when set.
///
/// Properties of `Content` should mutually exclusive with the properties of the
/// `StyledView.Style` and `BehaviorsConfigurableView.Behaviors`.
///
/// - SeeAlso: `BehaviorsConfigurableView`
/// - SeeAlso: `StyledView`
/// - SeeAlso: `EpoxyableView`
public protocol ContentConfigurableView: UIView {
  /// The `Equatable` properties that can be updated on instances of this view, e.g. text `String`s
  /// or image `URL`s.
  ///
  /// Defaults to `EmptyContent` for views that do not have `Content`.
  associatedtype Content: Equatable = EmptyContent

  /// Updates the content of this view to the properties of the given `content`, optionally
  /// animating the updates.
  func setContent(_ content: Self.Content, animated: Bool)
}

// MARK: Defaults

extension ContentConfigurableView where Content == EmptyContent {
  public func setContent(_ content: EmptyContent, animated: Bool) {
    // No-op
  }
}

// MARK: - EmptyContent

/// A type used to allow a view with no content to conform to `ContentConfigurableView`.
///
/// The default `Content` for `ContentConfigurableView`s that do not have a custom associated
/// `Content` type.
public struct EmptyContent: Equatable {
  /// The single shared instance of `EmptyContent`.
  public static let shared = EmptyContent()
}
