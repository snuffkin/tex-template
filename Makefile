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

.PHONY: all watch install clean distclean check help

all: distclean $(MAIN).pdf ## PDFをビルド

$(MAIN).pdf: main.tex latexmkrc $(wildcard src/*.tex)
	@TIMEFORMAT='==> ビルド時間: %R 秒'; time $(LATEXMK)

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
		texlive-pictures \
		texlive-luatex \
		texlive-lang-japanese \
		latexmk \
		biber \
		fonts-noto-cjk
	@echo "==> 導入完了。'make' でビルドできるか確認してください。"

clean: ## 中間ファイルを削除(PDF は残す)
	$(LATEXMK) -c
	@rm -rf build

distclean: ## PDFを含め生成物を全削除
	$(LATEXMK) -C
	@rm -rf build
	@rm -f $(MAIN).pdf

check: all ## 未定義参照・未定義引用・Overfull boxを確認
	@echo "=== 未定義参照 ==="
	@grep -cE "Reference .* undefined" build/$(MAIN).log || true
	@echo "=== 未定義引用 ==="
	@grep -cE "Citation .* undefined" build/$(MAIN).log || true
	@echo "=== Overfull \\hbox ==="
	@grep -cE "Overfull \\\\hbox" build/$(MAIN).log || true

help: ## このヘルプを表示
	@echo "使い方: make [target]"
	@echo ""
	@echo "利用可能なターゲット:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
