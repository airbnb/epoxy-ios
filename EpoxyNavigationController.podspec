Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyNavigationController',
    summary: 'Declarative API for driving the navigation stack of a UINavigationController',
    local_deps: ['EpoxyCore'])
end
