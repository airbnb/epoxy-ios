import EpoxyCore
import EpoxyLayoutGroups
import UIKit

// MARK: - EmbeddedView

final class EmbeddedView: UIView { }

// Inferred conformance isolation must not isolate generic model construction.
func model<View: UIView>(_: View.Type) -> GroupItem<View> {
  GroupItem(dataID: 1, make: { MainActor.assumeIsolated { View() } })
}

func subclassModel() -> GroupItem<EmbeddedView> {
  model(EmbeddedView.self)
}

func identityAndEquality(_ view: UIView, horizontal: HGroup, vertical: VGroup, spacer: LayoutSpacer) {
  let objects: [any Constrainable] = [view, horizontal, vertical, spacer]
  for object in objects {
    _ = object.dataID
    _ = object.isEqual(to: object)
    let container = ConstrainableContainer(object)
    _ = container.diffIdentifier
    _ = container.isEqual(to: container)
  }
  _ = spacer.isEqual(to: spacer)
}

@MainActor
func layout(_ object: any Constrainable, in view: UIView) {
  object.install(in: view)
  _ = object.layoutFrame
  _ = object.leadingAnchor
  object.constrainToMargins()
  object.uninstall()
}

#if INVALID_INSTALL
func invalidInstall(_ object: any Constrainable, in view: UIView) {
  object.install(in: view)
}
#endif

#if INVALID_FRAME
func invalidFrame(_ object: any Constrainable) {
  _ = object.layoutFrame
}
#endif

#if INVALID_ANCHOR
func invalidAnchor(_ object: any Constrainable) {
  _ = object.leadingAnchor
}
#endif
