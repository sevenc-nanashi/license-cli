# frozen_string_literal: true

require "bundler/gem_tasks"
task default: %i[]

task :licenses do
  require "net/https"
  require "json"
  require "dotenv"
  require_relative "lib/license/cli/colored_puts"

  Dotenv.load
  https = Net::HTTP.new("api.github.com", 443)
  https.use_ssl = true
  headers = {
    "Authorization": "token #{ENV["GITHUB_TOKEN"]}",
  }
  iputs "Fetching licenses..."
  licenses = JSON.parse(https.get("/licenses", headers).body, symbolize_names: true)
  ret = {}
  ret[:licenses] = licenses
  ret[:license_info] = {}
  licenses.each do |license|
    iputs "Fetching license info for #{license[:name]}..."
    license_info = {}
    license_info[:id] = license[:key]
    license_info[:name] = license[:name]
    license_info[:data] = JSON.parse(https.get("/licenses/#{license[:key]}", headers).body, symbolize_names: true)
    ret[:license_info][license[:key]] = license_info
  end

  iputs "Writing licenses..."
  File.open("lib/license/cli/licenses.json", "w") do |f|
    f.write(JSON.dump(ret))
  end

  sputs "Done."
end
