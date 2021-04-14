Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyLayoutGroups',
    summary: 'Declarative API for driving the subviews of a UIView',
    local_deps: ['EpoxyCore'])
end
