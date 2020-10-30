//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

public protocol EpoxyControlling: AnyObject {
  var dataID: String { get set }
  /// must be marked `weak`
  var delegate: EpoxyControllerDelegate? { get set }
  /// must be marked `weak`
  var interface: EpoxyInterface? { get set }
  func rebuild(animated: Bool)
  func makeSections() -> [EpoxySection]
  func hiddenDividerDataIDs() -> [AnyHashable]
  func invalidateAllEpoxyModels()
}
