// Created by nick_miller on 8/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public struct VisibleEpoxySectionMetadata {

  // MARK: Lifecycle

  public init(section: EpoxyableSection, modelMetadata: [VisibleEpoxyModelMetadata]) {
    self.section = section
    self.modelMetadata = modelMetadata
  }

  // MARK: Public

  public let section: EpoxyableSection
  public let modelMetadata: [VisibleEpoxyModelMetadata]
}
