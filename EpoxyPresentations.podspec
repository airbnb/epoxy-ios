Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyPresentations',
    summary: 'Declarative API for driving the modal presentations of a UIViewController',
    local_deps: ['EpoxyCore'])
end
