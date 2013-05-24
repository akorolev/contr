class TmeOauth
  attr_accessor :response
  def initialize
    @req_uri = 'https://api.trademe.co.nz/v1/'
    @consumer = OAuth::Consumer.new(Tokens.first.consumer_key, Tokens.first.consumer_secret,
                                    {:site => "https://secure.trademe.co.nz",
                                     :request_token_path => "/Oauth/RequestToken",
                                     :access_token_path => "/Oauth/AccessToken",
                                     :authorize_path => "/Oauth/Authorize"
                                    })
    @access_token = OAuth::AccessToken.new(@consumer, Tokens.first.oauth_token, Tokens.first.oauth_token_secret)
    @response = @access_token.get(@req_uri + 'MyTradeMe/Summary.json')
    #case @response
    #  when Net::HTTPSuccess then @response
    #  else raise "Access error!"
    #end
  end
  def get(path)
    @response = @access_token.get(@req_uri + path)
    case @response
#      when Net::HTTPSuccess then ActiveSupport::JSON.decode(response.body)
      when Net::HTTPSuccess then Hash.from_xml(response.body)
      when Net::HTTPBadRequest then throw :HTTPBadRequest
      when Net::HTTPUnauthorized then throw :HTTPUnauthorized
      else
        raise "HTTPOtherError"
    end
  end
end