require 'bundler/setup'
require 'sinatra'

require 'date'
require 'feedzirra'
require 'nokogiri'
require 'open-uri'
require 'gepub'

require 'pry'

Dir['./lib/*.rb'].each do |file|
  require file
end

require './app'

run Sinatra::Application
