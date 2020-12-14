Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyBars',
    summary: 'Declarative UI framework for fixed bar stacks',
    local_deps: ['EpoxyCore'])
end
