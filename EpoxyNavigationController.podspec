Pod::Spec.new do |s|
  s.name = 'EpoxyNavigationController'
  s.version = '0.36.1'
  s.license = 'Apache License, Version 2.0'
  s.summary = 'Declarative UI framework for UINavigationController'
  s.homepage = 'https://github.com/airbnb/epoxy-ios'
  s.authors = 'Airbnb'
  s.source = { git: 'https://github.com/airbnb/epoxy-ios', tag: s.version }
  s.source_files = "Sources/#{s.name}/**/*.swift"
  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.3']
  s.dependency 'EpoxyCore', "#{s.version}"
end
