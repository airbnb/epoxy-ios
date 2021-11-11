def xcpretty(cmd)
  sh "#{cmd} | xcpretty && exit ${PIPESTATUS[0]}"
end

namespace :build do
  desc 'Builds the Epoxy package'
  task :package do
    xcpretty 'xcodebuild build -scheme Epoxy -destination generic/platform=iOS'
  end

  desc 'Builds the EpoxyExample app'
  task :example do
    xcpretty 'xcodebuild build -scheme EpoxyExample -destination "platform=iOS Simulator,name=iPhone 12"'
  end
end

namespace :test do
  desc 'Runs all tests in the package'
  task :package => ['test:unit', 'test:performance']

  desc 'Runs unit tests'
  task :unit do
    xcpretty 'xcodebuild test -scheme EpoxyTests -destination "platform=iOS Simulator,name=iPhone 12"'
  end

  desc 'Runs performance tests'
  task :performance do
    xcpretty 'xcodebuild test -scheme PerformanceTests -destination "platform=iOS Simulator,name=iPhone 12"'
  end
end

namespace :lint do
  desc 'Lints the podspec'
  task :podspec do
    Dir.glob('*.podspec') do |spec|
      sh "bundle exec pod lib lint #{spec} --include-podspecs=**/*.podspec"
    end
  end

  desc 'Lints swift files'
  task :swift => 'bootstrap:mint' do
    sh 'mint run SwiftLint lint Sources Example --config script/lint/swiftlint.yml --strict'
    sh 'mint run SwiftFormat Sources Example --config script/lint/airbnb.swiftformat --lint '
  end
end

namespace :publish do
  desc 'Publishes the podspec'
  task :podspec do
    # Topologically sorted by dependencies
    podspecs = [
      'EpoxyCore',
      'EpoxyLayoutGroups',
      'EpoxyCollectionView',
      'EpoxyBars',
      'EpoxyNavigationController',
      'EpoxyPresentations',
      'Epoxy',
    ]

    for podspec in podspecs
      sh "bundle exec pod trunk push #{podspec}.podspec --synchronous"
      sh "bundle exec pod repo update"
    end
  end
end

namespace :format do
  desc 'Runs SwiftFormat'
  task :swift => 'bootstrap:mint' do
    sh 'mint run SwiftLint autocorrect Sources Example --config script/lint/swiftlint.yml'
    sh 'mint run SwiftFormat Sources Example --config script/lint/airbnb.swiftformat'
  end
end

namespace :bootstrap do
  task :mint do
    `which mint`
    throw 'You must have mint installed to lint or format swift' unless $?.success?
    sh 'mint bootstrap'
  end
end

namespace :run do
  desc 'Runs necessary checks before pushing a branch or commit'
  task :pre_push => ['format:swift', 'lint:swift', 'test:package']
end

task :default do
  system 'rake -T'
end
