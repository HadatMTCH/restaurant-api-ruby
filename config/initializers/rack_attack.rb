class Rack::Attack
  # Rate limit to 100 requests per minute per IP
  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip
  end

  # Rate limit login endpoints more strictly: 10 requests per minute per IP
  throttle("logins/ip", limit: 10, period: 1.minute) do |req|
    if req.path == "/login" && req.post?
      req.ip
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    headers = {
      "Content-Type" => "application/json"
    }
    [ 429, headers, [ { error: "Rate limit exceeded. Try again later." }.to_json ] ]
  end
end
