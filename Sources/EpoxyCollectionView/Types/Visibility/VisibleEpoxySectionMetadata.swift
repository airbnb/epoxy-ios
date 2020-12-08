// Created by nick_miller on 8/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public struct VisibleSectionMetadata {

  // MARK: Lifecycle

  public init(section: SectionModel, modelMetadata: [VisibleItemMetadata]) {
    self.section = section
    self.modelMetadata = modelMetadata
  }

  // MARK: Public

  public let section: SectionModel
  public let modelMetadata: [VisibleItemMetadata]
}
