require 'bundler/setup'
require 'date'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'gepub'

require './lib/fanfic'
require './lib/generator'
require './generate'

run Sinatra::Application
