#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple startup script for the demo app
puts "🏛️ Estonian e-Business Register API Demo"
puts "========================================="
puts

# Check if bundle is installed
puts "📦 Installing dependencies..."
system("bundle install --quiet")

puts "🚀 Starting Sinatra server on http://localhost:4567"
puts "   Press Ctrl+C to stop the server"
puts

# Load environment variables from .env file
if File.exist?('.env')
  File.readlines('.env').each do |line|
    key, value = line.strip.split('=', 2)
    ENV[key] = value if key && value
  end
  puts "✅ Environment variables loaded from .env"
else
  puts "⚠️  No .env file found. Copy .env.example to .env and add your API credentials."
end

puts

exec "bundle exec rackup -p 4567"