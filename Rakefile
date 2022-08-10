namespace :build do
  desc 'Builds the Epoxy package'
  task :package do
    xcodebuild 'build -scheme Epoxy -destination generic/platform=iOS'
  end

  desc 'Builds the EpoxyExample app'
  task :example do
    xcodebuild 'build -scheme EpoxyExample -destination "platform=iOS Simulator,name=iPhone 12"'
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
    formatTool('format --lint')
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
    formatTool('format')
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

def formatTool(command)
  # As of Xcode 13.4 / Xcode 14 beta 4, including airbnb/swift as a dependency
  # causes Xcode to spin indefinitely at 100% CPU (due to the remote binary dependencies
  # used by that package). As a workaround, we can specifically add that dependency
  # to our Package.swift file when linting / formatting and remove it afterwards.
  packageDefinition = File.read('Package.swift')
  resolvedPackages = File.read('Package.resolved')

  packageDefinitionWithFormatDependency = packageDefinition +
  <<~EOC
  
  #if swift(>=5.6)
  // Add the Airbnb Swift formatting plugin if possible
  package.dependencies.append(
    .package(
      url: "https://github.com/airbnb/swift",
      // Since we don't have a Package.resolved entry for this, we need to reference a specific commit
      // so changes to the style guide don't cause this repo's checks to start failing.
      .revision("cec29280c35dd6eccba415fa3bfc24c819eae887")))
  #endif
  EOC

  # Add the format tool dependency to our Package.swift
  File.write('Package.swift', packageDefinitionWithFormatDependency)

  exitCode = 0

  # Run the given command
  begin
    sh "swift package --allow-writing-to-package-directory #{command}"
  rescue
    exitCode = $?.exitstatus
  ensure
    # Revert the changes to Package.swift and Package.resolved
    File.write('Package.swift', packageDefinition)
    File.write('Package.resolved', resolvedPackages)
  end

  exit exitCode
end