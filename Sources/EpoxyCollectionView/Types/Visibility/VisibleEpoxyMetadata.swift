// Created by nick_miller on 8/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public struct VisibleEpoxyMetadata {

  // MARK: Lifecycle

  public init(
    sectionMetadata: [VisibleEpoxySectionMetadata],
    containerView: UIView?)
  {
    self.sectionMetadata = sectionMetadata
    self.containerView = containerView
  }

  // MARK: Public

  public let sectionMetadata: [VisibleEpoxySectionMetadata]
  public private(set) weak var containerView: UIView?
}
