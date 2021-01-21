task :build do
  sh 'xcodebuild build -scheme Epoxy-Package -destination generic/platform=iOS'
end

task :test do
  sh 'xcodebuild test -scheme Epoxy-Package -destination "platform=iOS Simulator,name=iPhone 8"'
end

namespace :lint do
  task :podspec do
    Dir.glob('*.podspec') do |spec|
      # Allow warnings to silence 'The URL (https://github.com/airbnb/epoxy-ios) is not reachable'
      sh "bundle exec pod lib lint #{spec} --include-podspecs=**/*.podspec --allow-warnings"
    end
  end

  task :swift do
    `which mint`
    throw 'You must have mint installed to lint swift' unless $?.success?
    sh 'mint bootstrap'
    sh 'mint run SwiftLint autocorrect --config script/lint/swiftlint.yml'
    sh 'mint run SwiftFormat . --config script/lint/airbnb.swiftformat'
  end
end
