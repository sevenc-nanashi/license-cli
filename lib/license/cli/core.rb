require "json"
require "tty-prompt"
require "colorize"
require "io/console/size"
require_relative "licenses"

module License::CLI
  HEIGHT, WIDTH = IO.console_size
  LICENSE_FIELDS = {}
  {
    ["yyyy", "year"] => [
      "Year of the license", Time.now.year,
    ],
    ["fullname", "name of author", "name of copyright owner"] => [
      "Name of copyright owner", ENV["USER"],
    ],

    ["one line to give the program's name and a brief idea of what it does."] => [
      "The program's name and a brief", nil,
    ],

    [
      "program",
    ] => [
      "The name of the program", Dir.pwd.split(/\/\\/).last,
    ],

  }.each do |key, value|
    key.each do |k|
      LICENSE_FIELDS[k] = value
    end
  end

  module_function

  def interactive
    prompt = TTY::Prompt.new
    license_name = prompt.select("Select Your license:", LICENSES[:licenses])
    license_key = LICENSES[:licenses].find { |l| l[:name] == license_name }
    license_sub_data = LICENSES[:license_info][license_key[:key]]
    license_data = license_sub_data[:data]
    puts "#{license_sub_data[:name]} is...".light_white
    puts "  Description:".light_black
    puts wrap(license_data[:description], WIDTH - 4)
           .split("\n")
           .map { |line| "    " + line }
           .join("\n")
    puts "  URL:".light_black
    puts "    " + license_data[:url]

    puts "This license's...".light_white
    if license_data[:permissions].any?
      puts "  Permissions:".green
      puts "   - " + license_data[:permissions].join("\n   - ")
    end
    if license_data[:conditions].any?
      puts "  Conditions:".red
      puts "   - " + license_data[:conditions].join("\n   - ")
    end
    if license_data[:limitations].any?
      puts "  Limitations:".yellow
      puts "   - " + license_data[:limitations].join("\n   - ")
    end
    puts
    accepted = prompt.yes?("Use this license?")

    exit 1 unless accepted

    license_file = prompt.ask("Where do you want to save this license?", default: "LICENSE")
    license_text = license_data[:body]

    fields = {}
    base_fields = license_text.scan(/[<\[](?!https?:\/\/).+?[>\]]/).uniq
    if base_fields.any?
      puts "There are some fields that you should fill in:".light_white

      base_fields.each do |raw_field|
        field = raw_field[1..-2]
        field_data = LICENSE_FIELDS[field]
        field_data ||= [field, ""]
        fields[raw_field] = prompt.ask(
          field_data[0] + "?",
          default: field_data[1],
        )
      end
      fields.each do |field, value|
        license_text.gsub!(field, value.to_s)
      end
    end
    File.write(license_file, license_text)
    puts "License saved to #{license_file}".green
  end

  def wrap(text, width)
    res = []
    line = +""
    text.split(/\s/).each do |word|
      tmp_line = line + word + " "
      if tmp_line.length > width
        res << line
        line = +(word + " ")
      else
        line = +tmp_line
      end
    end
    res << line
    res.map!(&:strip).join("\n")
  end
end
