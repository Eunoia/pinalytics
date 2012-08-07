require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'redis'
require 'sinatra'
require "sinatra/jsonp"



def getPin(pid)
	url = "http://pinterest.com/pin/#{pid||6262886952723741}/"
	doc = Nokogiri::HTML(open(url))
	data = {}

	title = doc.css("#PinCaption").text[/(.+)\n/].strip
	op    = doc.css("p:contains('Originally pinned by') a:first-child").text
	op = doc.css("#PinnerName a").text unless(op.length>1) 

	repins = doc.css("#PinRepins .PinRepinStory").length
	repins +=  doc.css("#PinRepins .PinMoreActivity").text[/\d+/].to_i

	likes =  doc.css("#PinLikes a").length
	likes += doc.css("#PinLikes .PinMoreActivity").text[/\d+/].to_i

	data = {
		:title  => title,
		:opinner => op,
		:likes   => likes,
		:repins  => repins,
		:ts      => Time.now().to_i
	}
	#REDIS.lpush("pid:"+pid,data)
	data
end

get '/:pid?' do
	#haml 'index.haml'
	jsonp getPin(params[:pid]||6262886952723741)
end