Pod::Spec.new do |s|
  s.name     = 'Epoxy'
  s.version  = '0.17.0'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'Declarative framework for UITableView and UICollectionView'
  s.homepage = 'https://github.com/airbnb/epoxy-ios'
  s.authors  = 'Airbnb'
  s.source   = { git: 'https://github.com/airbnb/epoxy-ios', tag: s.version }
  s.source_files = 'Epoxy/**/*.{swift,h}'
  s.public_header_files = 'Epoxy/*.h'
  s.frameworks = 'UIKit'
  s.ios.deployment_target = '11.0'
end
