# Configures the given Podspec with shared constants for all Epoxy podspecs.
def configure(spec:, name:, summary:, local_deps: [])
  # The shared CocoaPods version number for Epoxy.
  #
  # Change this constant to increment the Podspec version for all Epoxy Podspecs from a single place.
  version = '0.49.0'

  spec.name = name
  spec.summary = summary
  spec.version = version
  spec.license = 'Apache License, Version 2.0'
  spec.homepage = 'https://github.com/airbnb/epoxy-ios'
  spec.authors = 'Airbnb'
  spec.source = { git: 'https://github.com/airbnb/epoxy-ios', tag: version }
  spec.source_files = "Sources/#{name}/**/*.swift"
  spec.ios.deployment_target = '13.0'
  spec.swift_versions = ['5.3']

  local_deps.each do |dep|
    spec.dependency dep, version
  end
end
