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
require "escape"



def body_part title, body_html
	"<!DOCTYPE html><html><head>"+
		"<meta charset=\"UTF-8\"><title>#{title}</title><link href=\"/style.css\" rel=\"stylesheet\" type=\"text/css\"></head><body>"+
	body_html+"</body></html>"
end

# param:hash {"id":value}
def create_select_html to_uri, hash
	hash.map{|key, value|'<p><a href="'+to_uri+key.to_s+'">'+value+'</a></p>'}.join("")
end

# モンキーパッチなので、適用範囲を制限したほうが良いが、小さいプログラムなのでとりあえずこのままで。
class String
	def html_escape
		Escape.html_text(self)
	end
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
		create_select_html("/server/?serverid=", bot.servers.map{|s|[s[0], s[1].name.html_escape]}.to_h))
end

get "/server/" do
	id = request.params["serverid"].to_i
	begin
		server = bot.server(id)
	rescue Discordrb::Errors::NoPermission
		redirect to("/servers/")
	end
	body_part(server.name.html_escape,
		"<h1><a href=\"/servers/\">servers</a> &gt; #{server.name.html_escape}</h1>"+
			create_select_html("/channel/?channelid=",
				server.text_channels
					.map do |c|
						topic = (c.topic.nil? || c.topic.empty?)? "" :
							"<div style=\"margin-left: 3em;margin-top: -1em\">#{c.topic.html_escape.gsub(/\n+/){"<br>"}}</div>"
						[c.id, c.name.html_escape+topic]
					end.to_h))
end

# bodyタグではなく、timelineより下の部分が対象
def cleate_channel_main_html channel, server, before_id
	begin
		messages = channel.history(50, before_id = before_id)
	rescue Discordrb::Errors::NoPermission
		return "<p>このチャンネルを見る権限がありません</p>"
	end
	
	
	post_form = '<form method="post" action="/post/"><input type="hidden" name="channelid" value="'+channel.id.to_s+'">'+
		'<textarea name="text" rows="4" cols="59"></textarea><input type="submit"/></form>'
		
	return post_form+"<p>このチャンネルにはまだメッセージはありません。</p>" if messages.empty?
	
	timeline = "<div>"+messages.map do |msg|
		data = msg.creation_time.strftime("%Y-%m-%d-%H:%M:%S")
		name = msg.author.username.html_escape
		not_slash = /(?<!\\)/
		text = msg.text.html_escape
			.gsub("\t"){" "*8}.gsub(" "){"&nbsp;"}.gsub("\n"){"<br>"}
			.gsub(/#{not_slash}\*\*(.+?)\*\*/){"<strong>#{$1}</strong>"}
			.gsub(/#{not_slash}\*(.+?)\*/){"<em>#{$1}</em>"}
			.gsub(/#{not_slash}__(.+?)__/){"<u>#{$1}</u>"}
			.gsub(/#{not_slash}~~(.+?)~~/){"<s>#{$1}</s>"}
			.gsub(/#{not_slash}```((?:.|\s)+?)```/){"<pre><code>#{$1.gsub("<br>"){"\n"}.gsub("&nbsp;"){" "}}</code></pre>#{"&nbsp;"*4}"} # ここの実装微妙
			.gsub(/#{not_slash}`(.+?)`/){" <tt>#{$1}</tt> "}
			.gsub(/\\([*_`~])/){$1}
		"<div style=\"margin-top: 0.5em;\">"+data+" : "+name+" : "+text+"</div>"
	end.join("")+"</div>"
	
	next_link =
		if messages.length<50
			"<p>これ以上遡れません</p>"
		else
			# `-2`で、最後のメッセージが最初に来るように
			"<a href=/channel/?channelid=#{channel.id}&beforeid=#{(messages[-2])? messages[-2].id : messages[-1].id}>more</a>"
		end
	
	post_form+timeline+next_link
end

get "/channel/" do
	id = request.params["channelid"].to_i
	channel = bot.channel(id)
	if channel.nil?
		redirect to("/servers/")
	end
	server = channel.server
	before_id = (request.params.keys.include?("beforeid"))? request.params["beforeid"] : nil
	if !before_id.nil? &&  channel.load_message(before_id).nil?
		redirect to("/channel/?channelid=#{id}")
	end
	main = cleate_channel_main_html(channel, server, before_id)
	body_part(channel.name.html_escape,
		"<h1><a href=\"/servers/\">servers</a> &gt; <a href=\"/server/?serverid=#{server.id.to_s}\">#{server.name.html_escape}</a> &gt; "+
			"<a href=\"/channel/?channelid=#{id}\">#{channel.name.html_escape}</a></h1>#{(channel.topic.nil?)? "" : "<p>#{channel.topic.html_escape}</p>"}"+
		+main)
end

post "/post/" do
	id = request.params["channelid"].to_i
	channel = bot.channel(id)
	redirect to("/servers/") if channel.nil?
	text = request.params["text"]
	if text.empty?
		redirect to("/channel/?channelid=#{id}/")
	end
	begin
		channel.send_message(text)
	rescue Discordrb::Errors::NoPermission
		return body_part("NoParmission Error", "<p>投稿する権限がありません。</p><a href=\"/channel/?channelid=#{id}\">#{channel.name.html_escape}")
	end
	redirect to("/channel/?channelid=#{id}/")
end

not_found do
	body_part("404 not found", "<h1>404 not found</h1>このurlは間違っています。<a href=\"/\">top</a>")
end

get "/style.css" do
	[200, {"Content-Type" => "text/css"},
		"body{white-space: nowrap;}"+
		"em{font-style:oblique;}"+
		'tt,code{font-family:Consolas,Liberation Mono,Menlo,Courier,monospace;font-size:85%;}'+
		'pre{margin-left: 2em;}']
end
