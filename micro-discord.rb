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

def body_part title, body_html
	"<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>#{title}</title></head><body>"+
	body_html+"</body></html>"
end

# param:hash {"id":value}
def create_select_html to_uri, hash
	hash.map{|key, value|'<p><a href="'+to_uri+key.to_s+'">'+value+'</a></p>'}.join("")
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
	body_part("servers",
		"<h1>micro discord</h1>"+
		create_select_html("/server/?serverid=", bot.servers.map{|s|[s[0], s[1].name]}.to_h))
end

get "/server/" do
	id = request.params["serverid"].to_i
	server = bot.server(id)
	body_part(server.name,
		"<h1><a href=\"/servers/\">servers</a> &gt; #{server.name}</h1>"+
			create_select_html("/channel/?channelid=",
				server.channels.select{|c|c.type==0}
					.map do |c|
						topic = (c.topic.nil? || c.topic.empty?)? "" : "<div style=\"margin-left: 3em;margin-top: -1em\">#{c.topic.gsub(/\n+/){"<br>"}}</div>"
						[c.id, c.name+topic]
					end.to_h))
end

get "/channel/" do
	id = request.params["channelid"].to_i
	channel = bot.channel(id)
	server = channel.server
	timeline = channel
		.history(20)
		.map{|msg|
			data = msg.creation_time.strftime("%Y-%m-%d-%H:%M:%S")
			name = msg.author.username
			text = msg.text.gsub("\n"){"<br>"}.gsub(/\*\*(.*?)\*\*/){"<b>"+$1+"</b>"}
			"<p>"+data+" : "+name+" : <span style=\"white-space: nowrap\">"+text+"</span></p>"}
		.join("")
	body_part(channel.name,
		"<h1><a href=\"/servers/\">servers</a> &gt; <a href=\"/server/?serverid=#{server.id.to_s}\">#{server.name}</a> &gt; "+
			"#{channel.name}</h1>#{(channel.topic.nil?)? "" : "<p>#{channel.topic}</p>"}"+
		'<form method="post" action="/post/"><input type="hidden" name="channelid" value="'+id.to_s+'">'+
			'<input type="text" name="text"><input type="submit"/></form>'+
		"<div>"+timeline+"</div>")
end

post "/post/" do
	id = request.params["channelid"].to_i
	text = request.params["text"]
	bot.channel(id).send_message(text)
	redirect to("/channel/?channelid=#{id}/")
end
