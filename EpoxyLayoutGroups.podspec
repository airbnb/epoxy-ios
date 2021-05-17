Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyLayoutGroups',
    summary: 'Declarative API for building composable layouts in UIKit with a syntax similar to SwiftUI stack APIs',
    local_deps: ['EpoxyCore'])
end
