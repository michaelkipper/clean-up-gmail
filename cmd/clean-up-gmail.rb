require './lib/gmail.rb'

client = Gmail::Helper.new(options: {})

ids = client.get_message_ids('from:shopify.com')
msgs = client.op(ids)
