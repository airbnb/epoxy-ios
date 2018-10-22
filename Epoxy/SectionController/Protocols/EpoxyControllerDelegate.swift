//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

public protocol EpoxyControllerDelegate: AnyObject {
  func epoxyControllerDidUpdateData(_ epoxyController: EpoxyControlling, animated: Bool)
}
