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
    case .stopped where scrollView.isDragging && scrollView.contentOffset.y > scrollView.bounds.size.height:
      return .triggered
    case _ where scrollView.contentOffset.y < scrollView.bounds.size.height:
      return .stopped
    default:
      return self
    }
  }

}
