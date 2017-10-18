# encoding: UTF-8

puts "micro_discord [token] [client_id] [ipaddr]"
token = ARGV[0]
client_id = ARGV[1].to_i
ipaddr = ARGV[2]
puts "\nhttps://discordapp.com/oauth2/authorize?client_id=#{client_id}&scope=bot&permissions=3072"
puts "\nhttp://#{ipaddr}:4567"
print "\n\n"

require "sinatra"
require "discordrb"

def create_select_html select_name, action, option_html
	'<form method="get" action="'+action+'">'+
	'<select name="'+select_name+'" size="5">'+option_html+"</select>"+
	'<input type="submit"/></form>'
end

bot = Discordrb::Bot.new(
		token: token,
		client_id: client_id)

bot.run :async

set :bind, ipaddr

get "/" do
	redirect to("/servers/")
end

get "/servers/" do
	create_select_html("serverid", "/server/", bot.servers.map{|s|"<option value=\"#{s[0]}\">"+s[1].name+"</option>"}.join)
end

get "/server/" do
	id = request.params["serverid"].to_i
	create_select_html("channelid", "/channel/", bot.server(id).channels.select{|c|c.type==0}.map{|c|"<option value=\"#{c.id}\">"+c.name+"</option>"}.join)
end

get "/channel/" do
	id = request.params["channelid"].to_i
	timeline = bot.channel(id)
		.history(20)
		.map{|msg|
			data = msg.creation_time.strftime("%Y-%m-%d-%H:%M:%S")
			name = msg.author.username
			text = msg.text.gsub("\n"){"<br>"}.gsub(/\*\*(.*?)\*\*/){"<b>"+$1+"</b>"}
			"<p>"+data+" : "+name+" : <span style=\"white-space: nowrap\">"+text+"</span></p>"}
		.join("")
	'<form method="post" action="/post/"><input type="hidden" name="channelid" value="'+id.to_s+'">'+
		'<input type="text" name="text"><input type="submit"/></form>'+
	"<div>"+timeline+"</div>"
end

post "/post/" do
	id = request.params["channelid"].to_i
	text = request.params["text"]
	bot.channel(id).send_message(text)
	redirect to("/channel/?channelid=#{id}/")
end
