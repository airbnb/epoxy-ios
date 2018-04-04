//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

open class EpoxyMultiSectionController<SectionDataIDType>: EpoxyControlling
  where
  SectionDataIDType: StringRepresentable,
  SectionDataIDType: Hashable
{

  // MARK: Lifecycle

  public init() { }

  // MARK: Open

  open var dataID: String = ""

  open func sectionController(forDataID dataID: SectionDataIDType) -> EpoxySectionControlling? {
    return nil
  }

  open func hiddenDividerDataIDs() -> [String] {
    return allSectionControllers().flatMap { $0.hiddenDividerDataIDs() }
  }

  // MARK: Public

  public weak var navigator: EpoxyNavigable? {
    didSet { updateAllSectionControllerNavigators() }
  }

  public weak var delegate: EpoxyControllerDelegate? {
    didSet { didSetDelegate() }
  }

  public var sectionDataIDs = [SectionDataIDType]() {
    didSet { didUpdateSectionDataIDs() }
  }

  public func makeTableViewSections() -> [EpoxySection] {
    return sectionDataIDs.flatMap { dataID in
      return sectionController(forDataID: dataID)?.makeTableViewSection()
    }
  }

  public func makeCollectionViewSections() -> [EpoxyCollectionViewSection] {
    return sectionDataIDs.flatMap { dataID in
      return sectionController(forDataID: dataID)?.makeCollectionViewSection()
    }
  }

  public func allSectionControllers() -> [EpoxySectionControlling] {
    return sectionDataIDs.flatMap { dataID in
      return sectionController(forDataID: dataID)
    }
  }

  public func rebuildSection(forDataID dataID: SectionDataIDType, animated: Bool) {
    sectionController(forDataID: dataID)?.rebuild(animated: animated)
    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func rebuild(animated: Bool) {
    sectionDataIDs.forEach { dataID in
      rebuildSection(forDataID: dataID, animated: animated)
    }
    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  // MARK: Private

  private func didUpdateSectionDataIDs() {
    updateDelegates()
  }

  private func didSetDelegate() {
    updateDelegates()
  }

  private func updateDelegates() {
    updateAllSectionControllerDelegates()
    delegate?.epoxyControllerDidUpdateData(self, animated: true)
  }

  private func updateAllSectionControllerDelegates() {
    allSectionControllers().forEach { sectionController in
      sectionController.delegate = delegate
    }
  }

  private func updateAllSectionControllerNavigators() {
    allSectionControllers().forEach { sectionController in
      sectionController.navigator = navigator
    }
  }
}
