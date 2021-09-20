require "json"

module License::Cli
  LICENSES = JSON.parse(File.read("./licenses.json"))

  module_function

  def run

  end
end
