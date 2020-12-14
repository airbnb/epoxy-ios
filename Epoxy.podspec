Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'Epoxy',
    summary: 'Declarative UI framework for UIKit',
    local_deps: ['EpoxyCore', 'EpoxyCollectionView', 'EpoxyBars', 'EpoxyNavigationController'])
end
