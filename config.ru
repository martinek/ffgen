require 'bundler/setup'

require 'date'
require 'nokogiri'
require 'gepub'

require 'pry'

Dir['./lib/*.rb'].each do |file|
  require file
end

require './app'

$stdout.sync = true

run Sinatra::Application
