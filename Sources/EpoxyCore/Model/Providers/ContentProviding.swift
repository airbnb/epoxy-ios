// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - ContentProviding

/// The capability of providing an `Equatable` content instance.
public protocol ContentProviding {
  /// The `Equatable` content of this type.
  associatedtype Content: Equatable

  /// The `Equatable` content instance of this type.
  var content: Content { get }
}

// MARK: - ContentViewEpoxyModeled

extension ContentEpoxyModeled where Self: ContentProviding {

  // MARK: Public

  /// The `Equatable` content instance of this model.
  public var content: Content {
    get { self[contentProperty] }
    set { self[contentProperty] = newValue }
  }

  /// Returns a copy of this model with the content replaced with the provided content.
  public func content(_ value: Content) -> Self {
    copy(updating: contentProperty, to: value)
  }

  // MARK: Private

  private var contentProperty: EpoxyModelProperty<Content> {
    .init(
      keyPath: \Self.content,
      defaultValue: {
        fatalError("content must be set at init, this is programmer error")
      }(),
      updateStrategy: .replace)
  }
}
