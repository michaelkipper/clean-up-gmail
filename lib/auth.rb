require 'googleauth'
require 'googleauth/stores/file_token_store'

module Gmail
    class Auth
        LOG = Logger.new(STDOUT)
        OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

        class CredentialError < StandardError
        end

        attr_reader :options

        def initialize(options: {})
            LOG.info("Options: #{options.inspect}")
            @options = options
        end
        
        # Returns the path to the client_secrets.json file.
        def client_secrets_path
            return ENV['GOOGLE_CLIENT_SECRETS'] if ENV.has_key?('GOOGLE_CLIENT_SECRETS')
            return well_known_path_for('client_secrets.json')
        end
  
        # Returns the path to the token store.
        def token_store_path
            return ENV['GOOGLE_CREDENTIAL_STORE'] if ENV.has_key?('GOOGLE_CREDENTIAL_STORE')
            return well_known_path_for('credentials.yaml')
        end
    
        # Builds a path to a file in $HOME/.config/google (or %APPDATA%/google,
        # on Windows)
        def well_known_path_for(file)
            if OS.windows?
            dir = ENV.fetch('HOME'){ ENV['APPDATA']}
            File.join(dir, 'google', file)
            else
            File.join(ENV['HOME'], '.config', 'google', file)
            end
        end
    
        # Returns application credentials for the given scope.
        def application_credentials_for(scope)
            Google::Auth.get_application_default(scope)
        end
    
        # Returns user credentials for the given scope. Requests authorization
        # if requrired.
        def user_credentials_for(scope)
            LOG.info('auth.rb') { "Getting user credentials for #{scope}" }
            FileUtils.mkdir_p(File.dirname(token_store_path))

            raise ArgumentError, "Missing GOOGLE_CLIENT_ID" unless ENV['GOOGLE_CLIENT_ID']
            raise ArgumentError, "Missing GOOGLE_CLIENT_SECRET" unless ENV['GOOGLE_CLIENT_SECRET']

            client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
            token_store = Google::Auth::Stores::FileTokenStore.new(:file => token_store_path)
            authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)
    
            user_id = options[:user] || 'default'
    
            code = ENV['GOOGLE_CLIENT_CODE']
            unless code
                url = authorizer.get_authorization_url(base_url: OOB_URI)
                raise CredentialError, "Open the following URL in your browser and authorize the application: #{url}"
            end

            credentials = authorizer.get_credentials(user_id)
            if credentials.nil?
                credentials = authorizer.get_and_store_credentials_from_code(
                    user_id: user_id, code: code, base_url: OOB_URI)
            end
            credentials
        end
    
        # Gets the API key of the client
        def api_key
            ENV['GOOGLE_API_KEY'] || options[:api_key]
        end

        def api_code
            ENV['GOOGLE_API_CODE']
        end
    end
end
