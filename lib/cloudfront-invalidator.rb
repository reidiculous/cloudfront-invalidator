# All these libraries are in the Ruby standard library; no gems needed
require 'net/https'
require 'base64'
require 'hmac-sha1'
require 'rexml/document'

class CloudfrontInvalidator  
  def initialize(aws_key, aws_secret, cf_dist_id)
    @aws_key, @aws_secret, @cf_dist_id = aws_key, aws_secret, cf_dist_id
    
    @BASE_URL = "https://cloudfront.amazonaws.com/2010-11-01/distribution/"
  end
  
  def invalidate(*keys)
    keys = keys.flatten.map do |k| 
      k.start_with?('/') ? k : '/' + k 
    end
    
    uri = URI.parse "#{@BASE_URL}#{@cf_dist_id}/invalidation"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    body = xml_body(keys)
    resp = http.send_request 'POST', uri.path, body, headers
    puts resp.code
    puts resp.body
  end
  
  def list(show_detail = false)
    uri = URI.parse "#{@BASE_URL}#{@cf_dist_id}/invalidation"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = http.send_request 'GET', uri.path, '', headers

    doc = REXML::Document.new resp.body
    puts "MaxItems " + doc.elements["InvalidationList/MaxItems"].text + "; " + (doc.elements["InvalidationList/MaxItems"].text == "true" ? "truncated" : "not truncated")
    
    doc.each_element("/InvalidationList/InvalidationSummary") do |summary|
      invalidation_id = summary.elements["Id"].text
      summary_text = "ID " + invalidation_id + ": " + summary.elements["Status"].text

      if show_detail
        detail_doc = REXML::Document.new get_invalidation_detail_xml(invalidation_id)
        puts summary_text +
             "; Created at: " +
             detail_doc.elements["Invalidation/CreateTime"].text +
             '; Caller reference: "' +
             detail_doc.elements["Invalidation/InvalidationBatch/CallerReference"].text +
             '"'
        puts '  Invalidated URL paths:'
        
        puts "    " + detail_doc.elements.to_a('Invalidation/InvalidationBatch/Path').map { |path| path.text }.join(" ")
      else
        puts summary_text
      end
    end
  end
  
  def get_invalidation_detail_xml(invalidation_id)
    uri = URI.parse "#{@BASE_URL}#{@cf_dist_id}/invalidation/#{invalidation_id}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = http.send_request 'GET', uri.path, '', headers
    return resp.body
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