// Created by nick_miller on 8/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public struct VisibleEpoxyMetadata {

  // MARK: Lifecycle

  init(
    sectionMetadata: [VisibleEpoxySectionMetadata],
    containerView: UIView?)
  {
    self.sectionMetadata = sectionMetadata
    self.containerView = containerView
  }

  // MARK: Public

  public let sectionMetadata: [VisibleEpoxySectionMetadata]

  public var containerFrame: CGRect {
    return containerView?.frame ?? .zero
  }

  // MARK: Private

  private weak var containerView: UIView?
}

public extension VisibleEpoxyMetadata {
  var withModelFramesConvertedToContainerFrame: VisibleEpoxyMetadata {
    let containerView = self.containerView
    let convertedSectionMetadata: [VisibleEpoxySectionMetadata] = sectionMetadata.map({ section in
      let convertedModelMetdata: [VisibleEpoxyModelMetadata] = section.modelMetadata.compactMap({ model in
        guard let convertedFrame = containerView?.convert(model.frame, to: containerView?.superview) else {
          return nil
        }
        return VisibleEpoxyModelMetadata(
          model: model.model,
          frame: convertedFrame)
      })
      return VisibleEpoxySectionMetadata(
        section: section.section,
        modelMetadata: convertedModelMetdata)
    })
    return VisibleEpoxyMetadata(
      sectionMetadata: convertedSectionMetadata,
      containerView: containerView)
  }
}
