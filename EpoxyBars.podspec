Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyBars',
    summary: 'Declarative API for adding fixed top/bottom bar stacks to a UIViewController',
    local_deps: ['EpoxyCore'])
end
