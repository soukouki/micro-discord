# micro-discord
Simple Discord not to use javascript for

## usage

(ipaddr = local ip addres)

`gem install sinatra`

`gem install discordrb`

`https://discordapp.com/oauth2/authorize?client_id=[client-id]&scope=bot&permissions=3072`

`ruby micro_discord.rb [token] [client_id] [ipaddr]`

`http://[ipaddr]:4567`

## others

ローカルでサーバーを作り、Nintendo 3ds からもディスコードが見れる・投稿できるようになります。

え、HTMLの形式がひどいってレベルじゃないって・・？

うーん・・いつか直します・・・

### 未処理エラー
- 空文字列を投稿。
- 何も書いていないチャンネルを開く。
- 404
- beforeidが不正
- channelidが不正
- serveridが不正

### 未処理のもの(明確なバグではないが、修正したほうが良いもの)
- markdown(これはライブラリを使い、しっかり表示したほうが良いのではないか)
- 複数行のコメント
- 連続したスペース
