#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
args=(-typecheck -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)"
  -target "$(uname -m)-apple-ios13.0-simulator" -swift-version 6
  -strict-concurrency=complete -enable-upcoming-feature InferIsolatedConformances
  -warnings-as-errors -module-cache-path "$work/cache"
  Sources/EpoxyCollectionView/CollectionView/ReusableViews/ItemCellView.swift
  Sources/EpoxyCollectionView/Models/ItemModel/ItemCellState.swift
  Tests/CompilerTests/ItemWrapperView.swift)
xcrun swiftc "${args[@]}"
echo "ItemWrapperView compiler contracts passed"
