# Makefile
#
# 前提: latexmkとLuaLaTeX(TeX Live)が使えること。
#       整っていなければ`make install`を実行する(root権限が必要)。
#       root権限がない場合は`make install SUDO=sudo`のようにSUDOを指定する。

SHELL     := bash
MAIN      := main
LATEXMK   := latexmk
APT_GET   := apt-get

# root 権限で実行している場合は空のまま、一般ユーザーで sudo を使いたい場合は
# `make install SUDO=sudo` のように上書きする。デフォルトでは sudo を使わない。
SUDO      ?=

.PHONY: all rebuild watch install clean distclean check help

# 再ビルドの要否は latexmk が .fdb_latexmk で判定する (.bib や図も追跡される)
all: ## PDFをビルド(変更があった分だけ再コンパイル)
	@TIMEFORMAT='==> ビルド時間: %R 秒'; time $(LATEXMK)

rebuild: ## 生成物を全削除してからPDFをビルド
	$(MAKE) distclean
	$(MAKE) all

watch: ## 変更監視で自動リビルド
	$(LATEXMK) -pvc

# ---------------------------------------------------------------------------
# 環境構築
#
# root でない環境では、`make install SUDO=sudo` のように SUDO 変数に sudo を渡す
# ---------------------------------------------------------------------------
install: ## 必要パッケージをaptで導入(root前提、デフォルトはsudoなし。root権限がない場合: make install SUDO=sudo)
	@if [ -z "$(SUDO)" ] && [ "$$(id -u)" != "0" ]; then \
		echo "エラー: root 権限がありません。"; \
		echo "  次のいずれかを試してください。"; \
		echo "    make install SUDO=sudo   (sudo を使う)"; \
		echo "    sudo -i してから make install を実行する"; \
		exit 1; \
	fi
	@echo "==> apt-get update を実行します。"
	-$(SUDO) $(APT_GET) update
	$(SUDO) $(APT_GET) install -y --no-install-recommends \
		texlive-lang-japanese \
		texlive-latex-extra \
		texlive-fonts-extra \
		texlive-fonts-recommended \
		texlive-pictures \
		texlive-luatex \
		texlive-publishers \
		latexmk \
		biber \
		poppler-utils \
		fonts-noto-cjk
	@echo "==> 導入完了。'make' でビルドできるか確認してください。"

clean: ## 中間ファイルを削除(PDF は残す)
	$(LATEXMK) -c
	@rm -rf build

distclean: ## PDFを含め生成物を全削除
	$(LATEXMK) -C
	@rm -rf build
	@rm -f $(MAIN).pdf

check: all ## 未定義参照・未定義引用・Overfull box・フォント埋め込みを確認
	@echo "=== 未定義参照 ==="
	@grep -cE "Reference .* undefined" build/$(MAIN).log || true
	@echo "=== 未定義引用 ==="
	@grep -cE "Citation .* undefined" build/$(MAIN).log || true
	@echo "=== Overfull \\hbox ==="
	@grep -cE "Overfull \\\\hbox" build/$(MAIN).log || true
	@echo "=== フォント埋め込み ==="
	@if command -v pdffonts >/dev/null 2>&1; then \
		if pdffonts $(MAIN).pdf | awk 'NR>2 && $$(NF-4)=="no"{f=1; print} END{exit !f}'; then \
			echo "エラー: 上記のフォントがPDFに埋め込まれていません。"; exit 1; \
		else echo "OK(全フォント emb yes)"; fi; \
	else echo "pdffontsが無いためスキップしました(apt install poppler-utils)"; fi

help: ## このヘルプを表示
	@echo "使い方: make [target]"
	@echo ""
	@echo "利用可能なターゲット:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
