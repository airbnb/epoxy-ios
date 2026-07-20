# Configures the given Podspec with shared constants for all Epoxy podspecs.
def configure(spec:, name:, summary:, local_deps: [])
  # The shared CocoaPods version number for Epoxy.
  #
  # Change this constant to increment the Podspec version for all Epoxy Podspecs from a single place.
  version = '0.10.0'

  spec.name = name
  spec.summary = summary
  spec.version = version
  spec.license = 'Apache License, Version 2.0'
  spec.homepage = 'https://github.com/airbnb/epoxy-ios'
  spec.authors = 'Airbnb'
  spec.source = { git: 'https://github.com/airbnb/epoxy-ios.git', tag: version }
  spec.source_files = "Sources/#{name}/**/*.swift"
  spec.ios.deployment_target = '13.0'
  spec.swift_versions = ['6.0']
  # Match the SwiftPM build's default main-actor isolation (see Package.swift). CocoaPods doesn't
  # read the package's `swiftSettings`, so pass the same flags here to keep the isolation — and the
  # compiler's guarantees — identical across both distribution channels.
  spec.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-default-isolation MainActor -enable-upcoming-feature InferIsolatedConformances',
  }

  local_deps.each do |dep|
    spec.dependency dep, version
  end
end
