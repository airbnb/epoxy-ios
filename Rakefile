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
end
