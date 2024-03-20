namespace :build do
  desc 'Builds the Epoxy package'
  task :package do
    xcodebuild 'build -scheme Epoxy -destination generic/platform=iOS'
  end

  desc 'Builds the EpoxyCore package for iOS, macOS, and tvOS'
  task :EpoxyCore do
    xcodebuild 'build -scheme EpoxyCore -destination generic/platform=iOS'
    xcodebuild 'build -scheme EpoxyCore -destination generic/platform=tvOS'
    xcodebuild 'build -scheme EpoxyCore -destination generic/platform=macOS'
  end

  namespace :example do
    desc 'Builds the iOS EpoxyExample app'
    task :iOS do
      xcodebuild 'build -scheme EpoxyExample -destination "platform=iOS Simulator,name=iPhone 12"'
    end

    desc 'Builds the macOS Example app'
    task :macOS do
      xcodebuild 'build -workspace Example/Example-macOS.xcworkspace -scheme Example-macOS -destination generic/platform=macOS'
    end
  end
end

namespace :test do
  desc 'Runs all tests in the package'
  task :package => ['test:unit', 'test:performance']

  desc 'Runs unit tests'
  task :unit do
    xcodebuild 'test -scheme EpoxyTests -destination "platform=iOS Simulator,name=iPhone 12"'
  end

  desc 'Runs performance tests'
  task :performance do
    xcodebuild 'test -scheme PerformanceTests -destination "platform=iOS Simulator,name=iPhone 12"'
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
  task :swift do
    sh 'swift package --allow-writing-to-package-directory format --lint'
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
  desc 'Runs AirbnbSwiftFormatTool'
  task :swift do
    sh 'swift package --allow-writing-to-package-directory format'
  end
end

namespace :run do
  desc 'Runs necessary checks before pushing a branch or commit'
  task :pre_push => ['format:swift', 'lint:swift', 'test:package']
end

task :default do
  system 'rake -T'
end

private

def xcodebuild(command)
  # Check if the mint tool is installed -- if so, pipe the xcodebuild output through xcbeautify
  `which mint`

  if $?.success?
    sh "set -o pipefail && xcodebuild #{command} | mint run thii/xcbeautify@0.10.2"
  else
    sh "xcodebuild #{command}"
  end
end
