// Created by nick_miller on 8/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public struct VisibleItemMetadata {

  // MARK: Lifecycle

  public init(model: AnyItemModel, view: UIView? = nil) {
    self.model = model
    self.view = view
  }

  // MARK: Public

  public let model: AnyItemModel
  public private(set) weak var view: UIView?

}
