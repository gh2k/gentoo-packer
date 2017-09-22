require 'vagrant_cloud'

BOXEN = %w(gentoo-minimal gentoo-docker gentoo-docker-virt)
PROVIDERS = %w(hyperv vmware virtualbox)
PACKER_BUILD = ENV['PACKER_BUILD']
TOKEN = ENV['VAGRANT_CLOUD_TOKEN']

raise "Please set VAGRANT_CLOUD_TOKEN first" unless TOKEN

namespace :packer do
  namespace :ship do
    PROVIDERS.each do |provider|
      desc "Upload and release new box versions for #{provider} provider"
      task provider.to_sym do
        account = VagrantCloud::Account.new('symbols', TOKEN)
        raise "Failed to authenticate with Vagrant cloud" unless account

        version = Date.today.strftime('%Y.%-m.%-d')

        BOXEN.each do |box|
          puts "Creating #{box} version #{version}"
          b = account.ensure_box(box)
          v = b.ensure_version(version)
          raise "Failed to create version" unless version

          # Get updated description with package versions

          md = File.read("vagrantcloud/#{box}.md")
          description = File.read("vagrantcloud/#{box}.desc").chomp
          kernel_version = File.read("tmp/versions/gentoo-sources").chomp
          docker_version = File.read("tmp/versions/docker").chomp

          md = md.gsub('{{kernel_version}}', kernel_version)
                 .gsub('{{docker_version}}', docker_version)
          description = description.gsub('{{kernel_version}}', kernel_version)
                                   .gsub('{{docker_version}}', docker_version)

          puts "Uploading #{provider} provider for #{box} version #{version}"
          fn = "boxen/#{box}-#{provider}.box"
          p = v.ensure_provider(provider, fn)
          raise "Failed to upload" unless p

          b.update(description_markdown: md, short_description: description)
          v.update(description: description)

          puts "Releasing #{box} version #{version}"
          raise "Failed to release" unless v.release
        end
      end
    end

    desc "Upload and release new box versions for all providers"
    task :all do
      PROVIDERS.each { |provider| Rake::Task["packer:ship:#{provider}"].invoke }
    end
  end
end

task :default do
  puts "Run task `packer:ship:all` to deploy new versions for all providers. More info with `rake -T`"
end
