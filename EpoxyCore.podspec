Pod::Spec.new do |spec|
  # Update ConfigurePodspec.rb to increment the version number.
  require_relative 'ConfigurePodspec'
  configure(
    spec: spec,
    name: 'EpoxyCore',
    summary: 'Foundational APIs that are used to build all Epoxy declarative UI APIs')
end
