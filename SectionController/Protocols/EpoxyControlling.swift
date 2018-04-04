//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

public protocol EpoxyControlling: class {
  var dataID: String { get set }
  weak var delegate: EpoxyControllerDelegate? { get set }
  weak var navigator: EpoxyNavigable? { get set }
  func rebuild(animated: Bool)
  func makeTableViewSections() -> [EpoxySection]
  func makeCollectionViewSections() -> [EpoxyCollectionViewSection]
  func hiddenDividerDataIDs() -> [String]
}
