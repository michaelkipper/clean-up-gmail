# frozen_string_literal: true

require 'optparse'
require "./lib/gmail.rb"

options = {
  verbose: false,
}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.on("-v", "--[no-]verbose", FalseClass, "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG if options[:verbose]

def info(&block)
  LOG.info("clean_up_gmail.rb", &block)
end

client = Gmail::Helper.new

query = ARGV.pop
raise ArgumentError, "Query is required" if query.nil?

info { "Running query '#{query}'" }

ids = client.get_message_ids(query)
msgs = client.op(ids)
info { "Found #{msgs.length} message(s)" }

total = msgs.reduce(0) do |sum, msg|
  msg.respond_to?(:size_estimate) ? sum + msg.size_estimate : sum
end

info { "Total size estimate is #{total.to_s.reverse.scan(/\d{3}|.+/).join(',').reverse} byte(s)" }
