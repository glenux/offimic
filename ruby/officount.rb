#!/usr/bin/env ruby 

require 'sinatra'
require 'date'

get '/history' do
  File.open('history.csv', 'r') do |fh|
    fh.read 
  end 
end

get '/count/:value' do 
  value = params[:value]
  dt = DateTime.now
  File.open('history.csv', 'a') do |fh|
    fh.puts "#{dt.rfc3339}, #{value}"
  end
end 
