# micro-discord
Simple Discord not to use javascript for

## usage

```shellscript
gem install sinatra
gem install discordrb
gem install escape
```

`https://discordapp.com/oauth2/authorize?client_id=[client id]&scope=bot&permissions=3072`

`ruby micro_discord.rb [bot token] [bot client_id] [local ip addres]`

`http://[local ip addres]:4567`


## others

ローカルでサーバーを作り、Nintendo 3ds からもディスコードが見れる・投稿できるようになります。

### 未処理エラー
- 空文字列を投稿。
- 何も書いていないチャンネルを開く。
- beforeidが不正
- channelidが不正
- serveridが不正
