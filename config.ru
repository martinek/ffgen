require 'bundler/setup'
require 'sinatra'

require 'date'
require 'feedjira'
require 'nokogiri'
require 'open-uri'
require 'gepub'

require 'pry'

Dir['./lib/*.rb'].each do |file|
  require file
end

require './app'

$stdout.sync = true

run Sinatra::Application
