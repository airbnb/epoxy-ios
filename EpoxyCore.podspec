Pod::Spec.new do |s|
  s.name = 'EpoxyCore'
  s.version = '0.34.0'
  s.license = 'Apache License, Version 2.0'
  s.summary = 'Core of the Epoxy declarative UI framework for UIKit'
  s.homepage = 'https://github.com/airbnb/epoxy-ios'
  s.authors = 'Airbnb'
  s.source = { git: 'https://github.com/airbnb/epoxy-ios', tag: s.version }
  s.source_files = "Sources/#{s.name}/**/*.swift"
  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.3']
end
