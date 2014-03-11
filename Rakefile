require "rubygems"

# Could use gems for this but they're just one liners...
build = `/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" SmartChat/SmartChat-Info.plist`.chomp
version = `/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" SmartChat/SmartChat-Info.plist`.chomp
revision = `git log -1 --format="%h"`.chomp

destdir = "#{Dir.getwd}/build-#{version}-#{build}-#{revision}"

desc "Build for iPhone Simulator"
task :build do
  workspace = "SmartChat.xcworkspace"
  sdk = "iphonesimulator7.1"
  configuration = "Debug"
  scheme = "SmartChat"
  destdir = "#{destdir}/simulator-debug/"

  system %{xcodebuild -sdk #{sdk} -configuration #{configuration} -workspace #{workspace} -scheme #{scheme} CONFIGURATION_BUILD_DIR=#{destdir}}
  system "ios-sim launch #{destdir}/SmartChat.app --verbose"
end

namespace :test do
  desc "Run acceptnace tests"
  task :acceptance do
    workspace = "SmartChat.xcworkspace"
    sdk = "iphonesimulator7.1"
    configuration = "Debug"
    scheme = "SmartChatAcceptance"
    destdir = "#{destdir}/acceptance/"

    system %{xcodebuild -sdk #{sdk} -configuration #{configuration} -workspace #{workspace} -scheme #{scheme} CONFIGURATION_BUILD_DIR=#{destdir} test}
  end

  desc "Run unit tests"
  task :unit do
    workspace = "SmartChat.xcworkspace"
    sdk = "iphonesimulator7.1"
    configuration = "Debug"
    scheme = "SmartChat"
    destdir = "#{destdir}/test/"

    system %{xcodebuild -sdk #{sdk} -configuration #{configuration} -workspace #{workspace} -scheme #{scheme} CONFIGURATION_BUILD_DIR=#{destdir} test}
  end
end


task :default => :build
