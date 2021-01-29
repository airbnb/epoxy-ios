Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyCollectionView',
    summary: 'Declarative API for driving the content of a UICollectionView',
    local_deps: ['EpoxyCore'])
end
