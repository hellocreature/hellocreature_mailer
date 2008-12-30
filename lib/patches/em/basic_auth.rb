module EventMachine
module Protocols
 
class HttpClient < Connection

  # monkey patch to fix a bug in the basic auth implementation
  def send_request args
    args[:verb] ||= args[:method] # Support :method as an alternative to :verb.
    args[:verb] ||= :get # IS THIS A GOOD IDEA, to default to GET if nothing was specified?
 
    verb = args[:verb].to_s.upcase
    unless ["GET", "POST", "PUT", "DELETE", "HEAD"].include?(verb)
      set_deferred_status :failed, {:status => 0} # TODO, not signalling the error type
      return # NOTE THE EARLY RETURN, we're not sending any data.
    end
 
    request = args[:request] || "/"
    unless request[0,1] == "/"
      request = "/" + request
    end
 
    qs = args[:query_string] || ""
    if qs.length > 0 and qs[0,1] != '?'
      qs = "?" + qs
    end
 
    version = args[:version] || "1.1"
 
    # Allow an override for the host header if it's not the connect-string.
    host = args[:host_header] || args[:host] || "_"
    # For now, ALWAYS tuck in the port string, although we may want to omit it if it's the default.
    port = args[:port]
 
    # POST items.
    postcontenttype = args[:contenttype] || "application/octet-stream"
    postcontent = args[:content] || ""
    raise "oversized content in HTTP POST" if postcontent.length > MaxPostContentLength
 
    # ESSENTIAL for the request's line-endings to be CRLF, not LF. Some servers misbehave otherwise.
    # TODO: We ASSUME the caller wants to send a 1.1 request. May not be a good assumption.
    req = [
      "#{verb} #{request}#{qs} HTTP/#{version}",
      "Host: #{host}:#{port}",
      "User-agent: Ruby EventMachine",
    ]
 
    if verb == "POST" || verb == "PUT"
      req << "Content-type: #{postcontenttype}"
      req << "Content-length: #{postcontent.length}"
    end
 
    # TODO, this cookie handler assumes it's getting a single, semicolon-delimited string.
    # Eventually we will want to deal intelligently with arrays and hashes.
    if args[:cookie]
      req << "Cookie: #{args[:cookie]}"
    end
 
    # Basic-auth stanza contributed by Matt Murphy.
    if args[:basic_auth]
      basic_auth_string = ["#{args[:basic_auth][:username]}:#{args[:basic_auth][:password]}"].pack('m').strip.gsub(/\n/,'')
      req << "Authorization: Basic #{basic_auth_string}"
    end
 
    req << ""
    reqstring = req.map {|l| "#{l}\r\n"}.join
    send_data reqstring
 
    if verb == "POST" || verb == "PUT"
      send_data postcontent
    end
  end
 
end
 
 
end
end
