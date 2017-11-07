﻿# encoding: UTF-8

# 引数の処理、開くファイルなどの情報を出力する。
# discordrbがロード時に出力してしまうので、その前に
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

require "strscan"


# headなどの共通化のため。
def body_part title, body_html
	"<!DOCTYPE html><html lang=\"ja\"><head>"+
		"<meta charset=\"UTF-8\"><title>#{title}</title><link href=\"/style.css\" rel=\"stylesheet\" type=\"text/css\"></head><body>"+
	body_html+"</body></html>"
end

# param:hash {"id":value}
def create_select_html to_uri, hash
	'<div class="select-list">'+
		hash.map{|key, value|'<a href="'+to_uri+key.to_s+'">'+value+'</a><br>'}.join("")+"</div>"
end

# モンキーパッチなので、適用範囲を制限したほうが良いが、小さいプログラムなのでとりあえずこのままで。
class String
	def html_escape
		Escape.html_text(self)
	end
end

# ```__***~~test~~***__``` こんなのに備えて。
def markup markdown
	s = StringScanner.new(markdown)
	not_slash = /(?<!\\)/
	multi_line = /(?:.|\n)+?/
	single_backquote = /(?<!`)`(?!`)/
	html = ""
	until s.empty?
		html += case
		when s.scan(/#{not_slash}```(#{multi_line}+?)```/)
			'<div class="code-box"><pre><code>'+s[1]+"</code></pre></div>"
		when s.scan(/#{not_slash}#{single_backquote}(.+?)#{single_backquote}/)
			"<tt>#{s[1]}</tt>"
		when s.scan(/(#{multi_line})(?=#{not_slash}`|\z)/)
			markup_nonblock(s[1])
		end
	end
	html
end

def markup_nonblock markdown
	# http://sinya8282.sakura.ne.jp/?p=1064 より
	
	url_regexp =  '[a-z][-+.0-9a-z]*:(//(([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,:;=])*@)?(\[(([0-9a-f]{1,4}:){6}([0-9a-f]{1,4}:[0-9a-f]{1,4}|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))|::([0-9a-f]{1,4}:){5}([0-9a-f]{1,4}:[0-9a-f]{1,4}|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))|([0-9a-f]{1,4})?::([0-9a-f]{1,4}:){4}([0-9a-f]{1,4}:[0-9a-f]{1,4}|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))|(([0-9a-f]{1,4}:)?[0-9a-f]{1,4})?::([0-9a-f]{1,4}:){3}([0-9a-f]{1,4}:[0-9a-f]{1,4}|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))|(([0-9a-f]{1,4}:){0,2}[0-9a-f]{1,4})?::([0-9a-f]{1,4}:){2}([0-9a-f]{1,4}:[0-9a-f]{1,4}|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))|(([0-9a-f]{1,4}:){0,3}[0-9a-f]{1,4})?::[0-9a-f]{1,4}:([0-9a-f]{1,4}:[0-9a-f]{1,4}|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))|(([0-9a-f]{1,4}:){0,4}[0-9a-f]{1,4})?::([0-9a-f]{1,4}:[0-9a-f]{1,4}|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))|(([0-9a-f]{1,4}:){0,5}[0-9a-f]{1,4})?::[0-9a-f]{1,4}|(([0-9a-f]{1,4}:){0,6}[0-9a-f]{1,4})?::|v[0-9a-f]+\.[!$&-.0-;=_a-z~]+)\]|(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])|([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,;=])*)(:\d*)?(/([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,:;=@])*)*|/(([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,:;=@])+(/([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,:;=@])*)*)?|([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,:;=@])+(/([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,:;=@])*)*)?(\?([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,/:;=?@])*)?(#([-.0-9_a-z~]|%[0-9a-f][0-9a-f]|[!$&-,/:;=?@])*)?'
	
	s = StringScanner.new(markdown)
	not_slash = /(?<!\\)/
	multi_line = /(?:.|\n)+?/
	html = ""
	# かなりの回数呼ばれるため、正規表現には`o`オプションを付ける。
	until s.eos?
		html += case
		when s.scan(/#{not_slash}(#{url_regexp})/io)
			"<a href=\"#{s[1]}\" class=\"outside-link\">#{s[1]}</a>"
		when s.scan(/[^*_~\s\\]+/) # 高速化
			s[0].html_escape
		when s.scan(/#{not_slash}\*\*(#{multi_line})\*\*/o)
			"<strong>#{s[1]}</strong>"
		when s.scan(/#{not_slash}\*(#{multi_line})\*/o)
			"<em>#{s[1]}</em>"
		when s.scan(/#{not_slash}__(#{multi_line})__/o)
			"<u>#{s[1]}</u>"
		when s.scan(/#{not_slash}~~(#{multi_line})~~/o)
			"<s>#{s[1]}</s>"
		when s.scan(/\n/)
			"<br>"
		when s.scan(/[ \t]+/)
			"&nbsp;"*s[0].gsub("\t"){" "*8}.length
		when s.scan(/\\([*_`~])/)
			s[1]
		else
			s.getch.html_escape
		end
	end
	html
end


bot = Discordrb::Bot.new(token: token, client_id: client_id)
bot.ready{|e|
	puts "ネット回復時、自動的に表示されるので、それの対策"
	bot.invisible
}
bot.run :async

FutureStatus = Struct.new(:update_time, :status, :game)
future_status = FutureStatus.new(Time.now, :invisible, nil)
# 同期バグが起こる可能性はあるが、メイン部分ではないので許容する。
Thread.start do
	loop do
		fs = future_status
		# なにも入ってない時
		if fs.nil?
			sleep 10
			next
		end
		now = Time.now
		sleep fs.update_time-now if now<fs.update_time
		next if fs!=future_status # もし更新されていたら戻る
		bot.update_status(fs.status, fs.game, nil)
		future_status = nil
	end
end

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
							"<div class=\"server-topic\">#{c.topic.html_escape.gsub(/\n+/){"<br>"}}</div>"
						[c.id, c.name.html_escape+topic]
					end.to_h))
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
	
	# どこのチャンネルを見ているのかを表示させる
	if before_id.nil?
		bot.update_status(:online, "#{channel.name}を見ているかも", nil)
	else
		bot.update_status(:idle, "#{channel.name}の過去ログを見ているかも", nil)
	end
	future_status = FutureStatus.new(Time.now+60, :invisible, nil)
	
	main = cleate_channel_main_html(channel, server, before_id)
	body_part(channel.name.html_escape,
		"<h1><a href=\"/servers/\">servers</a> &gt; <a href=\"/server/?serverid=#{server.id.to_s}\">#{server.name.html_escape}</a> &gt; "+
			"<a href=\"/channel/?channelid=#{id}\">#{channel.name.html_escape}</a></h1>"+
				"#{(channel.topic.nil?)? "" : "<p>#{channel.topic.html_escape}</p>"}"+
		+main)
end

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
		text = markup(msg.text.html_escape)
		"<div style=\"margin-top: 0.5em;\">"+data+" : "+name+" : "+text+"</div>"
	end.join("")+"</div>"
	
	next_link =
		if messages.length<50
			"<p>これ以上遡れません</p>"
		else
			# `-2`で、最後のメッセージが最初に来るように
			"<a href=\"/channel/?channelid=#{channel.id}&beforeid=#{(messages[-2])? messages[-2].id : messages[-1].id}\">more</a>"
		end
	post_form+timeline+next_link
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

# デザイン初心者です。いいデザイン案があるなら、https://github.com/soukouki/micro-discord にプルリクエストをください。
get "/style.css" do
	[200, {"Content-Type" => "text/css"}, <<"EOS"

body { background:#111; color:#eee;}
a {color:#0af;}
em {font-style:oblique;}
pre {margin-left: 2em;}
textarea {background:#333; color:#eee;}
tt,code {font-family:Consolas,Liberation Mono,Menlo,Courier,monospace;font-size:85%;}
tt,.code-box {border: 1px solid #555;}
.select-list {margin:1em}
.server-topic {margin-left:3em; margin-top:0em}
.outside-link {background:#001}

EOS
]
end
