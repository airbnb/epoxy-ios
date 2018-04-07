//  Created by gonzalo_nunez on 6/22/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

enum InfiniteScrollingState {
  case loading
  case stopped
  case triggered

  func next(in scrollView: UIScrollView) -> InfiniteScrollingState {
    switch self {
    case .loading:
      return self
    case .triggered where !scrollView.isDragging:
      return .loading
    case .stopped where scrollView.isDragging && closeToBottom(scrollView: scrollView):
      return .triggered
    case _ where !closeToBottom(scrollView: scrollView):
      return .stopped
    default:
      return self
    }
  }

  private func closeToBottom(scrollView: UIScrollView) -> Bool {
    let threshold: CGFloat = scrollView.bounds.height
    let distanceFromBottom = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height)
    return distanceFromBottom <= threshold
  }
}
