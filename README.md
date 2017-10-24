# micro-discord
Simple discord client not to use javascript for

## usage

`gem install discordrb sinatra escape`

`https://discordapp.com/oauth2/authorize?client_id=[bot client id]&scope=bot&permissions=3072`

`ruby micro_discord.rb [bot token] [bot client id] localhost`

`http://localhost:4567`

## 機能など

### 対応している機能
- チャンネルを読む。(過去ログ含む)
	- markdown記法(コードブロック含む)に対応しています。
		- 基本はディスコード公式クライアントと同じ動作をするようにしています
- チャンネルに書き込む。
- 見ているチャンネルをgameに表示する。

### 非対応、未実装のもの
- シンタックスハイライト
- DM
- グループDM
- ボイス関連
- ユーザー情報の観覧
- サーバーに入っているユーザーの観覧
- 絵文字
- 画像
- ファイル
- 埋め込み

## others

ローカルでサーバーを作り、Nintendo 3ds からもディスコードが見れる・投稿できるようになります。

いいデザインがあったらください。

改造などがしやすいよう、一ファイルに纏めています。
自分の好きな機能を追加し、自分の嫌いな機能を捨てていきましょう！

改善案などは
[issue](https://github.com/soukouki/micro-discord/issues)にてお願いします。
