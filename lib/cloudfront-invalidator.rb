require 'net/https'
require 'base64'
require 'hmac-sha1'

class CloudfrontInvalidator
  
  def initialize(aws_key, aws_secret, cf_dist_id)
    @aws_key, @aws_secret, @cf_dist_id = aws_key, aws_secret, cf_dist_id
  end
  
  def invalidate(*keys)
    keys = keys.flatten.map do |k| 
      k.start_with?('/') ? k : '/' + k 
    end
    
    uri = URI.parse "https://cloudfront.amazonaws.com/2010-11-01/distribution/#{@cf_dist_id}/invalidation"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    body = xml_body(keys)
    resp = http.send_request 'POST', uri.path, body, headers
    puts resp.code
    puts resp.body
  end
  
  def xml_body(keys)
    xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
  <InvalidationBatch>
    #{keys.map{|k| "<Path>#{k}</Path>" }.join("\n    ")}
    <CallerReference>CloudfrontInvalidator at #{Time.now}</CallerReference>"
  </InvalidationBatch>
XML
  end
  
  def headers
    date = Time.now.strftime('%a, %d %b %Y %H:%M:%S %Z')
    digest = HMAC::SHA1.new(@aws_secret)
    digest << date
    signature = Base64.encode64(digest.digest)
    {'Date' =>  date, 'Authorization' => "AWS #{@aws_key}:#{signature}"}
  end
  
end