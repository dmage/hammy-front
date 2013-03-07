#!/usr/bin/env ruby

require 'sinatra'
require 'couchbase'

cb = Couchbase.connect(:bucket => "config", :hostname => "localhost")

set :haml, :format => :html5

get '/' do
	haml :index
end

get '/all_triggers' do
	keys = []

	hammy = cb.design_docs['hammy']
	hammy.all_keys.each { |doc|
		keys << doc.key
	}

	haml :all_triggers, :locals => {:keys => keys}
end

get '/trigger/:key' do |key|
	haml :editor, :locals => {:key => key}
end

get '/get_trigger' do
	code = ""
	begin
		code = cb.get(params[:key])
	rescue Couchbase::Error::NotFound
	end
	code
end

post '/save_trigger' do
	res = cb.set(params[:key], params[:code])
	puts "new code for key '#{params[:key]}':\n#{params[:code]}"
	"Saved! #{res}"
end