require 'curb'
require 'json'
require 'semantic'
require 'uri'

def get_version(box, token)
  response = JSON.parse(
    Curl::Easy.http_get("https://atlas.hashicorp.com/api/v1/box/symbols/#{box}") do |curl|
      curl.headers["X-Atlas-Token"] = token
    end.body
  )
  raise response["errors"].join("\n") if response["errors"]

  response['versions'].map { |v| Semantic::Version.new(v['version']) }.sort.last
end

def add_new_version(box, token)
  version = get_version(box, token).patch!

  puts "Creating new version #{version} for symbols/#{box}"

  version_data = {
    "version": {
      "version": version.to_s
    }
  }.to_json
  response = JSON.parse((
    Curl::Easy.http_post("https://atlas.hashicorp.com/api/v1/box/symbols/#{box}/versions", version_data) do |curl|
      curl.headers["X-Atlas-Token"] = token
      curl.headers['Content-Type'] = 'application/json'
    end
  ).body)
  raise response["errors"].join("\n") if response["errors"]

  version
end

def update_version_description(box, version, token)
  puts "Updating descripion for symbols/#{box}:#{version}"

  md = File.read("vagrantcloud/#{box}.md")
  description = File.read("vagrantcloud/#{box}.desc").chomp
  kernel_version = File.read("tmp/versions/gentoo-sources").chomp
  docker_version = File.read("tmp/versions/docker").chomp

  md = md.gsub('{{kernel_version}}', kernel_version)
         .gsub('{{docker_version}}', docker_version)
  description = description.gsub('{{kernel_version}}', kernel_version)
                           .gsub('{{docker_version}}', docker_version)

  box_data = {
    "box": {
      "short_description": description,
      "description": md
    }
  }.to_json
  response = JSON.parse((
    Curl::Easy.http_put("https://atlas.hashicorp.com/api/v1/box/symbols/#{box}",  box_data) do |curl|
      curl.headers["X-Atlas-Token"] = token
      curl.headers['Content-Type'] = 'application/json'
    end
  ).body)
  raise response["errors"].join("\n") if response["errors"]

  version_data = {
    "version": {
      "description": md
    }
  }.to_json
  response = JSON.parse((
    Curl::Easy.http_put("https://atlas.hashicorp.com/api/v1/box/symbols/#{box}/version/#{version}", version_data) do |curl|
      curl.headers["X-Atlas-Token"] = token
      curl.headers['Content-Type'] = 'application/json'
    end
  ).body)
  raise response["errors"].join("\n") if response["errors"]

  true
end

def build(box, token)
  new_version = add_new_version(box, token)

  system({'VAGRANT_BOX_VERSION' => new_version.to_s}, "packer build #{box}.json")

  update_version_description(box, new_version, token)

  puts "Finished building new box - symbols/#{box}:#{new_version}"

  new_version
end