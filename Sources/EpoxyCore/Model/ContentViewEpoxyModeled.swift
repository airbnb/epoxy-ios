// Created by eric_horacek on 12/1/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

/// An Epoxy model with both an associated `UIView` and `Equatable` content type.
public protocol ContentViewEpoxyModeled: ViewEpoxyModeled, ContentEpoxyModeled {}
