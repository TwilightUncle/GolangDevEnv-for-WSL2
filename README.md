# GolangDevEnv-for-WSL2
WindowsにおいてWSL2の上にDockerを用いてGolangの開発環境を構築  

## 環境
Windos10, Windows11が対象  
`WSL2`(最新), `Docker Desktop`がインストールされていること

## 使用方法
### 1.ソースコードダウンロード
```ps1
cd path/to/dir
git clone git@github.com:TwilightUncle/GolangDevEnv-for-WSL2.git
```

### 2.設定ファイルの展開と変更
#### variables.ps1
`variables.ps1.sample`を複製して`variables.ps1`を作成する。  
上記で作成したファイルの変数を必要に応じて変更する。

- $DISTRO_NAME - WSLに登録されるディストリビューション名。ここに指定した名称で`wsl -d <$DISTRO_NAME>`を実行することで構築した環境にログイン可能
- $GO_VERSION - 開発環境で使用するGOバージョンを指定
- $TIME_ZONE - タイムゾーン
- $VSCODE_BIN_PATH - ホストにインストール済みのvscodeバイナリのパスを指定する。構築した環境からのドライブ名は`C:/`であれば`/c/`と指定する
- $GIT_BIN_PATH - ホストにインストール済みのgitバイナリのパスを指定する。※ホストのgitの設定をそのまま使いまわすため
- $DEFAULT_USER - 開発環境へ接続した際のデフォルトユーザー名
- $DEFAULT_USER_PASSWORD - 開発環境のデフォルトユーザーのパスワード

#### server_files/configure/wsl.conf
`wsl.conf.sample`を複製して`wsl.conf`を作成する。  
各設定項目については[マイクロソフトのリファレンス](https://learn.microsoft.com/ja-jp/windows/wsl/wsl-config#configuration-settings-for-wslconf)を参照

#### server_files/configure/initialize.sh
`initialize.sh.sample`を複製して`initialize.sh`を作成する。  
上記で作成したファイルには、アプリケーションソースの展開等、開発環境上で最初に一度だけ行いたい処理を記述する。

### 3.構築、ログイン等
以下のコマンドで開発環境を構築する  
Dockerは起動中であること  
```ps1
cd /path/to/PhpEnvBuild-for-WSL2

# 構築
./build.ps1

# いらない場合、Dockerのキャッシュを削除する
docker builder prune
```

以下、ログイン及び構築した環境の破棄  
Dockerは起動不要
```ps1
# 開発環境へログイン
wsl -d <variables.ps1のDISTRO_NAMEに指定した名称>

# いらなくなった開発環境を削除
wsl --unregister <variables.ps1のDISTRO_NAMEに指定した名称>
```

### 4.接続元のWindowsとWSL上でのSSH秘密鍵の共有
Gitリモートリポジトリへの接続等を行う等、SSH関連の設定しなければいけない場合がある。   
しかし、環境設定の変更などで一旦WSLに構築済みのdistroを破棄し、再度構築すると、SSH関連の設定を構築の度に実施しないといけなくなってしまうため手間である。  
そこで、本項では既にWindows上でもGitを用いた開発を行っており、SSH鍵を作成済みであるものとして、以下にWSLに構築した開発環境上でもWindows上に存在する秘密鍵をWSLで流用できるように設定するコマンド手順を記載する。  
※コマンドの実行はWSL上に構築済みの開発環境にログインして行う。  

```sh
chmod 600 /mnt/c/Users/<ユーザー名>/.ssh/<秘密鍵のファイル名>
eval `ssh-agent`
ssh-add /mnt/c/Users/<ユーザー名>/.ssh/<秘密鍵のファイル名>
```
