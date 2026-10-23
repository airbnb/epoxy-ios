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
  Tests/CompilerTests/Constrainable.swift)
for version in 5 6; do
  xcrun swiftc "${args[@]}" -swift-version "$version"
  for contract in INSTALL FRAME ANCHOR; do
    if xcrun swiftc "${args[@]}" -swift-version "$version" -D "INVALID_$contract" > "$work/negative.log" 2>&1; then
      echo "Expected off-actor $contract access to fail" >&2
      exit 1
    fi
    grep -q 'main actor-isolated' "$work/negative.log"
  done
done
echo "Constrainable compiler contracts passed"
