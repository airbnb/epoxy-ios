// Created by eric_horacek on 4/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy

// MARK: - CoordinatedBarModel

/// A bar model with a custom content type and `Coordinator` that is responsible for providing the
/// `BarModel` that will be displayed to the user.
public struct CoordinatedBarModel {

  // MARK: Lifecycle

  public init<Coordinator: BarCoordinating, Content: Equatable>(
    dataID: AnyHashable,
    content: Content,
    barModel: Coordinator.Model,
    makeCoordinator: @escaping (_ update: @escaping (_ animated: Bool) -> Void) -> Coordinator)
  {
    self.dataID = dataID
    self.content = content

    typealias CoordinatorWrapper = AnyBarCoordinator<Coordinator.Model>

    _makeCoordinator = { CoordinatorWrapper(makeCoordinator($0)) }

    _barModel = { coordinator in
      guard let typedCoordinator = coordinator as? CoordinatorWrapper else {
        assertionFailure("\(coordinator) is not of the expected type \(CoordinatorWrapper.self)")
        return nil
      }
      return typedCoordinator.barModel(for: barModel)
    }

    _canReuseCoordinator = { coordinator in
      guard let typedCoordinator = coordinator as? CoordinatorWrapper else {
        assertionFailure("\(coordinator) is not of the expected type \(CoordinatorWrapper.self)")
        return false
      }
      return typedCoordinator.type == Coordinator.self
    }

    _isDiffableItemEqual = { other in
      guard let other = other as? CoordinatedBarModel else { return false }
      guard let otherContent = other.content as? Content else { return false }
      return otherContent == content
    }
  }

  // MARK: Private

  private let dataID: AnyHashable
  private let content: Any
  private let _isDiffableItemEqual: (Diffable) -> Bool
  private let _makeCoordinator: (_ update: @escaping (_ animated: Bool) -> Void) -> AnyBarCoordinating
  private let _canReuseCoordinator: (_ coordinator: AnyBarCoordinating) -> Bool
  private let _barModel: (_ coordinator: AnyBarCoordinating) -> BarModeling?
}

// MARK: BarModeling

extension CoordinatedBarModel: BarModeling {
  public var barModel: AnyBarModel { .init(self) }
}

// MARK: InternalBarCoordinating

extension CoordinatedBarModel: InternalBarCoordinating {
  func makeCoordinator(update: @escaping (Bool) -> Void) -> AnyBarCoordinating {
    _makeCoordinator(update)
  }

  func barModel(for coordinator: AnyBarCoordinating) -> BarModeling {
    _barModel(coordinator) ?? self
  }

  func canReuseCoordinator(_ coordinator: AnyBarCoordinating) -> Bool {
    _canReuseCoordinator(coordinator)
  }
}

// MARK: Diffable

extension CoordinatedBarModel: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    _isDiffableItemEqual(otherDiffableItem)
  }

  public var diffIdentifier: AnyHashable? {
    dataID
  }
}
