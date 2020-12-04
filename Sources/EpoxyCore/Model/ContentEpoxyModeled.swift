// Created by eric_horacek on 12/4/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

/// An Epoxy model with an associated `Equatable` `Content` type.
public protocol ContentEpoxyModeled: EpoxyModeled {
  /// The content type associated with this model.
  ///
  /// Content is typically set on a corresponding view initially when it is created and subsequently
  /// whenever it changes.
  associatedtype Content: Equatable
}
