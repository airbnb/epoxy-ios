//  Created by Laura Skelton on 6/30/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

open class EpoxyCollectionViewController: EpoxyViewController {

  // MARK: Lifecycle

  public init(collectionViewLayout: UICollectionViewLayout) {
    self.collectionViewLayout = collectionViewLayout
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  /// Override this in your subclass to return your Epoxy sections
  open override func epoxySections() -> [EpoxySection] {
    return []
  }

  /// Returns a `CollectionView` by default. Override this to configure another view type.
  open override func makeEpoxyView() -> EpoxyView {
    return CollectionView(collectionViewLayout: collectionViewLayout)
  }

  // MARK: Private

  private let collectionViewLayout: UICollectionViewLayout

}
