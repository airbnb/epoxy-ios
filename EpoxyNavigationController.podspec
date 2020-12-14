Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyNavigationController',
    summary: 'Declarative UI framework for UINavigationController',
    local_deps: ['EpoxyCore'])
end
