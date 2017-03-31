require_relative 'vagrantcloud/builder'

BOXEN = %w(gentoo-minimal gentoo-docker)
TOKEN = ENV['VAGRANT_CLOUD_TOKEN']

raise "Please set VAGRANT_CLOUD_TOKEN first" unless TOKEN

namespace :build do
  desc "Builds the specified box"
  task :build, [:box] do |t, args|
    build(args[:box], TOKEN)
  end

  BOXEN.each do |box|
    desc "Builds and uploads the symbols/#{box} box"
    task box.to_s do
      Rake.application.invoke_task("build:build[#{box}]")
    end
  end

  desc "Builds and uploads all of the boxen"
  task :all do
    BOXEN.each do |box|
      Rake.application.invoke_task("build:#{box}")
    end
  end
end

desc "Alias for build:all"
task build: :'build:all'