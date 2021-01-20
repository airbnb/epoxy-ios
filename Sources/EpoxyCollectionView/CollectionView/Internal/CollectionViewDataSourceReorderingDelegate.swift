// Created by eric_horacek on 1/19/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

// MARK: - CollectionViewDataSourceReorderingDelegate

protocol CollectionViewDataSourceReorderingDelegate: AnyObject {
  func dataSource(
    _ dataSource: CollectionViewDataSource,
    moveItem sourceItem: AnyItemModel,
    inSection sourceSection: SectionModel,
    toDestinationItem destinationItem: AnyItemModel,
    inSection destinationSection: SectionModel)
}
