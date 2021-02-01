namespace :build do
  task :package do
    sh 'xcodebuild build -scheme Epoxy -destination generic/platform=iOS'
  end

  task :example do
    sh 'xcodebuild build -scheme EpoxyExample -destination "platform=iOS Simulator,name=iPhone 8"'
  end
end

namespace :test do
  task :package => ['test:unit', 'test:performance']

  task :unit do
    sh 'xcodebuild test -scheme EpoxyTests -destination "platform=iOS Simulator,name=iPhone 8"'
  end

  task :performance do
    sh 'xcodebuild test -scheme PerformanceTests -destination "platform=iOS Simulator,name=iPhone 8"'
  end
end

namespace :lint do
  task :podspec do
    Dir.glob('*.podspec') do |spec|
      sh "bundle exec pod lib lint #{spec} --include-podspecs=**/*.podspec"
    end
  end

  task :swift => 'bootstrap:mint' do
    sh 'mint run SwiftLint lint Sources Example --config script/lint/swiftlint.yml --strict'
    sh 'mint run SwiftFormat Sources Example --config script/lint/airbnb.swiftformat --lint '
  end
end

namespace :format do
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
