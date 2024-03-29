// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - ErasedContentProviding

/// The capability of providing an type-erased `Equatable` content instance.
public protocol ErasedContentProviding {
  /// The type-erased content instance of this model, else `nil` if there is no content.
  ///
  /// If there was an `AnyEquatable` type, we could store this property using it. Instead we need
  /// need to store `isErasedContentEqual` to determine equality.
  var erasedContent: Any? { get }

  /// A closure that can be called to determine whether the given `model`'s `erasedContent` is equal
  /// to this model's `erasedContent`, else `nil` if there is no content or the content is always
  /// equal.
  var isErasedContentEqual: ((ErasedContentProviding) -> Bool)? { get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: ErasedContentProviding {

  // MARK: Public

  /// The type-erased content instance of this model, else `nil` if there is no content.
  public var erasedContent: Any? {
    get { self[contentProperty] }
    set { self[contentProperty] = newValue }
  }

  /// A closure that can be called to determine whether the given `model`'s `erasedContent` is equal
  /// to this model's `erasedContent`, else `nil` if there is no content or the content is always
  /// equal.
  public var isErasedContentEqual: ((ErasedContentProviding) -> Bool)? {
    get { self[isContentEqualProperty] }
    set { self[isContentEqualProperty] = newValue }
  }

  // MARK: Private

  private var contentProperty: EpoxyModelProperty<Any?> {
    .init(keyPath: \ErasedContentProviding.erasedContent, defaultValue: nil, updateStrategy: .replace)
  }

  private var isContentEqualProperty: EpoxyModelProperty<((ErasedContentProviding) -> Bool)?> {
    .init(keyPath: \ErasedContentProviding.isErasedContentEqual, defaultValue: nil, updateStrategy: .replace)
  }
}
