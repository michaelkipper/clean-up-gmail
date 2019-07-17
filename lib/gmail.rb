require 'google/apis/gmail_v1'

require './lib/auth.rb'

module Gmail
    class MessageWrapper
        extend Forwardable

        def_delegators :@msg, :label_ids, :thread_id, :size_estimate, :snippet

        def initialize(msg)
            @msg = msg
        end

        def to_s
            "#{date}: (#{from}) - #{snippet}"
        end

        def header_value(key, default: nil)
            headers = @msg.payload.headers
            headers.any? { |h| h.name == key } ? headers.find { |i| i.name == key }.value : default
        end

        def date
            header_value('Date', default: '')
        end

        def from
            header_value('From')
        end

        def to
            header_value('To')
        end

        def cc
            header_value('Cc')
        end

        def bcc
            header_value('Bcc')
        end

        def subject
            header_value('Subject', default: 'No Subject')
        end
    end

    class Helper
        LOG = Logger.new(STDOUT)

        def initialize(options: {})
            @gmail = ::Google::Apis::GmailV1::GmailService.new
            @auth = ::Gmail::Auth.new
            @gmail.authorization = @auth.user_credentials_for(Google::Apis::GmailV1::AUTH_SCOPE)
        end

        def get_message_ids(query)
            @gmail.fetch_all(max: 500, items: :messages) do |token|
                @gmail.list_user_messages('me', max_results: 500, q: query, page_token: token)
            end.map(&:id)
        end

        def create_wrapper(result, err)
            if err
                LOG.error('callback') { "Error: #{err.inspect}" }
            else
                MessageWrapper.new(result)
            end
        end

        def op(ids)
            messages = []
            ids.each_slice(1000) do |ids_array|
                @gmail.batch do |gm|
                    ids_array.map do |id|
                        gm.get_user_message('me', id) do |result, err|
                            messages << create_wrapper(result, err)
                        end
                    end
                end
            end
            messages
        end
    end
end
