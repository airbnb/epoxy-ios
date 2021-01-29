// Created by eric_horacek on 10/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - ModalTransitioning

extension ModalTransitioning {
  /// Presents the given model as a view controller, optionally animating the presentation.
  ///
  /// A `nil` `model` is treated as a dismissal.
  ///
  /// If a transition is in progress when this method is called, the provided model is queued for
  /// subsequent presentation.
  ///
  /// Conceptually similar `setSections(_:animated:)` for Epoxy models.
  public func setPresentation(_ model: PresentationModel?, animated: Bool) {
    queue.enqueue(model, animated: animated, from: self)
  }
}

private extension ModalTransitioning {
  /// The queue of in progress presentations for this view controller.
  @nonobjc
  var queue: PresentationQueue {
    if let queue = objc_getAssociatedObject(self, &Keys.queue) as? PresentationQueue {
      return queue
    }
    let queue = PresentationQueue()
    objc_setAssociatedObject(self, &Keys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return queue
  }
}

// MARK: - Keys

/// Associated object keys.
private enum Keys {
  static var queue = 0
}
