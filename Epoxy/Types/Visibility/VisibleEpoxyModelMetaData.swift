// Created by nick_miller on 8/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public struct VisibleEpoxyModelMetadata {

  // MARK: Lifecycle

  public init(model: EpoxyableModel, view: UIView? = nil) {
    self.model = model
    self.view = view
  }

  // MARK: Public

  public let model: EpoxyableModel
  public private(set) weak var view: UIView?

}
