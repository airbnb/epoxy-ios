import EpoxyBars
import EpoxyCollectionView
import EpoxyCore
import EpoxyLayoutGroups
import UIKit

// Storing actor-isolated behavior callbacks must not isolate model construction.
func models() {
  _ = ItemModel<UIView>(dataID: 1).setBehaviors { $0.view.alpha = 0.5 }
  _ = SupplementaryItemModel<UIView>(dataID: 2).setBehaviors { $0.view.alpha = 0.5 }
  _ = BarModel<UIView>(dataID: 3).setBehaviors { $0.view.alpha = 0.5 }
}

// The independent Constrainable isolation change enables off-actor group construction.
@MainActor
func groupModel() {
  _ = GroupItem<UIView>(dataID: 4, make: { MainActor.assumeIsolated { UIView() } })
    .setBehaviors { $0.constrainable.alpha = 0.5 }
}

@MainActor
func invoke(_ callback: ItemModel<UIView>.SetBehaviors, context: ItemModel<UIView>.CallbackContext) {
  callback(context)
}

#if INVALID_OFF_ACTOR
func invalid(_ callback: ItemModel<UIView>.SetBehaviors, context: ItemModel<UIView>.CallbackContext) {
  callback(context)
}
#endif
