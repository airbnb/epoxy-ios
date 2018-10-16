//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

public protocol EpoxySectionControlling: EpoxyControlling {
  func makeTableViewSection() -> EpoxySection
  func makeCollectionViewSection() -> EpoxyCollectionViewSection
}
