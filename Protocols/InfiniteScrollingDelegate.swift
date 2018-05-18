//  Created by gonzalo_nunez on 6/22/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

// MARK: - InfiniteScrollingDelegate

/// Protocol to handle loading of new content for infinite scrolling
public protocol InfiniteScrollingDelegate: class {
  /** 
    Called when more content should be loaded.
    - parameters:
      - completionHandler: Block to inform the delegate's owner to finish loading
  */
  func didScrollToInfiniteLoader(completionHandler: @escaping () -> Void)

  /// Return `false` if you no longer need need infinite scrolling aka you've loaded all content
  func shouldFireInfiniteScrolling() -> Bool
}

public extension InfiniteScrollingDelegate {

  public func shouldFireInfiniteScrolling() -> Bool {
    return true
  }
}
