#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
require "securerandom"
require "stringio"
require "uri"

USAGE = "Usage: HOMEPAGE_API_TOKEN=<token> " \
  "script/upload_gallery_image.rb <gallery_id> <file>"
DEFAULT_BASE_URL = "https://app.jutonz.com"

class ProgressStream
  def initialize(parts, total:, label:)
    @parts = parts
    @total = total
    @label = label
    @sent = 0
  end

  def read(length = nil, outbuf = nil)
    chunk = next_chunk(length)
    return nil if chunk.nil?

    @sent += chunk.bytesize
    report
    outbuf ? outbuf.replace(chunk) : chunk
  end

  private

  def next_chunk(length)
    while (part = @parts.first)
      chunk = part.read(length)
      return chunk unless chunk.nil? || chunk.empty?
      @parts.shift
    end
  end

  def report
    percent = (@sent * 100 / @total).floor
    $stderr.print(
      "\rUploading #{@label}: #{percent}% " \
      "(#{megabytes(@sent)} / #{megabytes(@total)} MB)"
    )
    warn("") if @sent == @total
  end

  def megabytes(bytes)
    format("%.1f", bytes / 1_048_576.0)
  end
end

def multipart_parts(file, filename, boundary)
  head = "--#{boundary}\r\n" \
    "Content-Disposition: form-data; name=\"file\"; " \
    "filename=\"#{filename.gsub('"', "%22")}\"\r\n" \
    "Content-Type: application/octet-stream\r\n\r\n"
  tail = "\r\n--#{boundary}--\r\n"
  [StringIO.new(head), file, StringIO.new(tail)]
end

def build_request(uri, token, file, filename)
  boundary = SecureRandom.hex(20)
  parts = multipart_parts(file, filename, boundary)
  total = parts.sum(&:size)

  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{token}"
  request["Accept"] = "application/json"
  request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
  request.content_length = total
  request.body_stream = ProgressStream.new(parts, total:, label: filename)
  request
end

gallery_id, file_path = ARGV
token = ENV["HOMEPAGE_API_TOKEN"]

abort(USAGE) if file_path.nil? || gallery_id.nil? || token.to_s.empty?
abort("File not found: #{file_path}") unless File.file?(file_path)

base_url = ENV.fetch("HOMEPAGE_URL", DEFAULT_BASE_URL)
uri = URI.join(base_url, "/api/galleries/#{gallery_id}/images")
filename = File.basename(file_path)

CONNECTION_LOST_ERRORS = [
  EOFError,
  Errno::ECONNRESET,
  Net::ReadTimeout,
  OpenSSL::SSL::SSLError
].freeze

begin
  response = File.open(file_path, "rb") do |file|
    request = build_request(uri, token, file, filename)
    Net::HTTP.start(
      uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 600
    ) do |http|
      http.request(request)
    end
  end
rescue *CONNECTION_LOST_ERRORS => error
  abort(
    "Connection lost before the server replied (#{error.class}). " \
    "The server may still have saved #{filename}; check gallery " \
    "#{gallery_id} before you upload it again."
  )
end

body = begin
  JSON.parse(response.body)
rescue JSON::ParserError
  response.body
end

if response.is_a?(Net::HTTPSuccess)
  puts("Uploaded #{filename} as image #{body["id"]}")
else
  abort("Upload failed (#{response.code}): #{body}")
end
