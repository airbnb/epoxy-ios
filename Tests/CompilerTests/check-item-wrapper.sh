#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
args=(-typecheck -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)"
  -target "$(uname -m)-apple-ios13.0-simulator"
  -strict-concurrency=complete -enable-upcoming-feature InferIsolatedConformances
  -warnings-as-errors -module-cache-path "$work/cache"
  Sources/EpoxyCollectionView/CollectionView/ReusableViews/ItemCellView.swift
  Sources/EpoxyCollectionView/Models/ItemModel/ItemCellState.swift
  Tests/CompilerTests/ItemWrapperView.swift)
for version in 5 6; do
  xcrun swiftc "${args[@]}" -swift-version "$version"
done
echo "ItemWrapperView compiler contracts passed"
