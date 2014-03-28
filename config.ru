require 'bundler/setup'
require 'date'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'gepub'

require './lib/fanfic'
require './lib/generator'

require './app'
run Sinatra::Application
