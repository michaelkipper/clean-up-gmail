# frozen_string_literal: true

require 'byebug'
require "./lib/gmail.rb"

LOG = Logger.new(STDOUT)

client = Gmail::Helper.new

QUERIES = [
  "from:emailbedbathandbeyond.com",
  "from:em.harborfreight.com",
  "from:rs.email.nextdoor.com",
]

QUERIES.each do |query|
  LOG.info("clean_up_gmail.rb") { "Running query '#{query}'" }

  ids = client.get_message_ids(query)
  msgs = client.op(ids)
  LOG.info("clean_up_gmail.rb") { "Found #{msgs.length} message(s)" }

  total = msgs.reduce(0) do |sum, msg|
    begin
      sum + msg.size_estimate
    rescue NoMethodError => e
      LOG.error("clean_up_gmail.rb") { "Could not reduce: #{e}" }
      sum
    end
  end
  LOG.info("clean_up_gmail.rb") { "Size estimate is #{total} bytes" }
end
