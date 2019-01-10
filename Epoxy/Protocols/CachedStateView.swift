//
//  CachedStateView.swift
//  Epoxy
//
//  Created by Kieraj Mumick on 11/12/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

import Foundation

public typealias RestorableState = Any

/// Provides the local state of the view. If the view is reused in a table/collection view, this
/// state will be saved upon preparing for reuse, and re-applied upon being reused.
public protocol CachedStateView: AnyObject {
  var cachedViewState: RestorableState? { get set }
}
