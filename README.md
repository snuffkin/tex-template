# TeXプロジェクトのテンプレート

TeXによる執筆プロジェクト

## ディレクトリ構成

```text
├── src/                     本文（1ファイル1章、章番号は付けない）
│   └── <各章>.tex
├── figures/                 章ごとの図版置き場（TikZ を本文に直書きする場合は不要）
│   └── <各章と同名のディレクトリ>/
├── bibliography/
│   └── references.bib       参考文献データベース（biblatex + biber で使用）
├── main.tex                 プリアンブルと \include の並び（章の順序はここで決まる）
├── main.pdf                 ビルド成果物（コミット対象）
├── build/                   latexmk の中間ファイル置き場（.gitignore 対象、コミットしない）
├── latexmkrc                latexmk のビルド設定（LuaLaTeX 使用）
├── Makefile                 latexmk の薄いラッパー、環境構築コマンド
├── .gitignore
└── README.md
```

### 章の順序について

`src/` のファイル名には章番号を含めていません。章構成の変更（挿入・削除・並べ替え）は
`main.tex` の `\include` の並びを編集するだけで完結し、ファイル名の一括リネームは不要です。

## このテンプレートを使った新規プロジェクトの始め方

1. `main.tex` の `\title`・`\author`（および `hyperref` の `pdftitle`・`pdfauthor`）を書き換える。
2. `src/` に章ファイルを追加し、`main.tex` の `\include` リストを編集する
   （`src/introduction.tex` はサンプルなので、書き換えるかコピーして増やす）。
3. 図は `figures/<章と同名のディレクトリ>/` に置いて `\includegraphics` で読み込むか、
   サンプル章のように `tikzpicture` を本文に直書きする。
4. 参考文献は `bibliography/references.bib` に追記し、`\cite{}` で引用する
   （同梱の2件のサンプル文献は削除して構わない）。
5. 索引に載せたい用語は `\index{}` で登録する（`\printindex` で巻末に出力される）。

なお、本テンプレートはビルド成果物（`main.pdf`）もリポジトリにコミットする運用です。
コミット前に `make` を実行し、PDF を最新の内容に更新してください。

## ビルド方法

### 必要な環境

- TeX Live（LuaLaTeX、`luatexja` パッケージ一式）
- Noto Serif/Sans CJK JP フォント
- `latexmk`

環境が整っていない場合：

```sh
make install
```

`apt` を直接呼びます。**`sudo` は使いません**。root 権限で実行するか、
`apt` が権限なしで使える環境（Docker コンテナ等）で実行してください。
root でない環境では、あらかじめ各自の方法で管理者権限を得てから実行してください。

### ビルド

```sh
make            # TeXをビルドし、PDFを生成
make watch      # ソースの変更を監視して自動リビルド
make clean      # 中間ファイルを削除(PDFは残す)
make distclean  # PDFを含めて生成物を全削除
make check      # 未定義参照・未定義引用・Overfull boxが無いか確認
make help       # 利用可能なコマンド一覧を表示
```

`latexmk` を経由せず直接コンパイルする場合：

```sh
lualatex main.tex
lualatex main.tex
lualatex main.tex
```

（相互参照・目次を確定させるため 3 回程度実行してください。）

## 組版環境

- エンジン：LuaLaTeX + LuaTeX-ja
- 和文フォント：Noto Serif CJK JP／Noto Sans CJK JP（デフォルトの構成）
- クラス：`ltjsbook`（章立てのある文書向け。デフォルトの構成）

新規に文書を LaTeX で組む場合、和文の扱いは pLaTeX/upLaTeX（jsclasses 系）と
LuaLaTeX + LuaTeX-ja のいずれかが主な選択肢です。本テンプレートは OpenType フォントを
そのまま扱え、変換ステップが不要な LuaLaTeX + LuaTeX-ja を採用しています。

書籍以外（論文・レポート・技術文書など、章立てが不要な文書）で使う場合は、
`main.tex` の `\documentclass{ltjsbook}` を `ltjsarticle` や `ltjsreport` などに
変更してください。その場合 `\frontmatter`／`\mainmatter`／`\chapter` 系の命令は
使えなくなるため、`\section` ベースの構成に読み替える必要があります。
