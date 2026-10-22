#!/bin/bash
set -euo pipefail
modules=${1:?Pass the Debug-iphonesimulator build products directory}
cd "$(dirname "$0")/../.."
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
args=(-typecheck -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)"
  -target "$(uname -m)-apple-ios15.0-simulator"
  -strict-concurrency=complete -enable-upcoming-feature InferIsolatedConformances
  -warnings-as-errors -module-cache-path "$work/cache" -I "$modules"
  Tests/CompilerTests/SetBehaviors.swift)
for version in 5 6; do
  xcrun swiftc "${args[@]}" -swift-version "$version"
  if xcrun swiftc "${args[@]}" -swift-version "$version" -D INVALID_OFF_ACTOR > "$work/negative.log" 2>&1; then
    echo "Expected off-actor behavior invocation to fail" >&2
    exit 1
  fi
  grep -q "main actor-isolated" "$work/negative.log"
done
echo "SetBehaviors compiler contracts passed"
