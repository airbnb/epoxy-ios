// Created by andrea_cipriani on 7/11/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

import Foundation
import Quick

// MARK: - MainActorSpec

/// Opt-in for `QuickSpec`s that exercise `@MainActor` types.
///
/// Quick's `spec()` stores its `beforeEach` / `it` / `afterEach` closures as nonisolated
/// `@escaping` closures and invokes them later, so a `@MainActor` annotation on the spec class or
/// on `spec()` doesn't reach them. Conforming to `MainActorSpec` runs each example closure on the
/// main actor, letting the spec call into `@MainActor` types directly without annotating every
/// closure.
protocol MainActorSpec: QuickSpec { }

extension MainActorSpec {
  func beforeEach(_ closure: @escaping @MainActor () -> Void) {
    Quick.beforeEach { runOnMainActor(closure) }
  }

  func afterEach(_ closure: @escaping @MainActor () -> Void) {
    Quick.afterEach { runOnMainActor(closure) }
  }

  func it(
    _ description: String,
    file: FileString = #file,
    line: UInt = #line,
    closure: @escaping @MainActor () throws -> Void)
  {
    Quick.it(description, file: file, line: line) {
      try runOnMainActor(closure)
    }
  }
}

/// Runs `work` on the main actor.
///
/// Quick invokes its example closures synchronously. That is usually — but not guaranteed to be —
/// on the main thread, so hop explicitly instead of unconditionally calling
/// `MainActor.assumeIsolated`, which traps with `SIGABRT` when invoked off the main thread.
private func runOnMainActor<T>(_ work: @MainActor () throws -> T) rethrows -> T {
  if Thread.isMainThread {
    return try MainActor.assumeIsolated(work)
  }
  return try DispatchQueue.main.sync { try MainActor.assumeIsolated(work) }
}
