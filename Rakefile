require 'vagrant_cloud'

BOXEN = %w(gentoo-minimal gentoo-docker gentoo-docker-virt)
PROVIDERS = %w(hyperv vmware virtualbox)
PACKER_BUILD = ENV['PACKER_BUILD']
TOKEN = ENV['VAGRANT_CLOUD_TOKEN']

raise "Please set VAGRANT_CLOUD_TOKEN first" unless TOKEN

desc "Upload and release new box versions"
task :ship do
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

    PROVIDERS.each do |provider|
      puts "Uploading #{provider} provider for #{box} version #{version}"
      fn = "boxen/#{box}-#{provider}.box"
      p = v.ensure_provider(provider, fn)
      raise "Failed to upload" unless p
    end

    b.update(description_markdown: md, short_description: description)
    v.update(description: description)

    puts "Releasing #{box} version #{version}"
    raise "Failed to release" unless v.release
  end
end

task :default do
  puts "Run task `ship` to deploy new version"
end
