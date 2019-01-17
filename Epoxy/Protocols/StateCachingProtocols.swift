//
//  StateCachingProtocols.swift
//  Epoxy
//
//  Created by Kieraj Mumick on 1/16/19.
//  Copyright © 2019 Airbnb. All rights reserved.
//

public typealias RestorableState = Any

/// A protocol for views that have ephemeral state (i.e., expansion state).
/// Epoxy uses the cached ephemeral state to automatically restore state when cells
/// are recycled.
public protocol EphemeralCachedStateView: AnyObject {
  var cachedEphemeralState: Any? { get set }
}
