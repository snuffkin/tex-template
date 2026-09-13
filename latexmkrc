# latexmkrc — LuaLaTeX + LuaTeX-ja 用ビルド設定
#
# 使い方:
#   latexmk               # ビルド（差分のみ再コンパイル）
#   latexmk -pvc          # ファイル変更を監視して自動リビルド
#   latexmk -c            # 中間ファイルを削除（PDF は残す）
#   latexmk -C            # PDF を含めて全て削除

# PDF を LuaLaTeX で直接生成するモード
$pdf_mode = 4;                 # 4 = lualatex
$lualatex = 'lualatex -synctex=1 -file-line-error -halt-on-error -interaction=nonstopmode %O %S';

# メインファイル
@default_files = ('main.tex');

# src/*.tex など、\include されるファイルの依存関係を正しく追跡
$dependents_list = 1;

# 中間ファイルは build/ に、最終PDFはルートに置く
# ( aux_dir と out_dir が異なる場合、latexmk は aux_dir でコンパイルしてから
#   最終成果物 (PDF) だけを out_dir にコピーする )
$aux_dir  = 'build';
$out_dir  = '.';

# \include{src/...} は src/*.aux を aux_dir 以下に書き込もうとするため、
# 対応するサブディレクトリを事前に用意しておく
mkdir $aux_dir unless -d $aux_dir;
mkdir "$aux_dir/src" unless -d "$aux_dir/src";

# 参考文献
# biblatex + biber を使う場合は latexmk が自動判定するので、通常は明示設定不要
# $bibtex_use = 2;
# $biber = 'biber %O %S';

# 日本語索引
$makeindex = 'upmendex %O -o %D %S';

# ビルド後に消してよい中間ファイルの拡張子
$clean_ext = 'synctex.gz synctex.gz(busy) run.xml bbl bcf fdb_latexmk fls idx ind ilg';

# latexmk -C ではさらに完全に削除
$clean_full_ext = 'fdb_latexmk fls';

# プレビューは自動起動しない
$preview_continuous_mode = 0;
$preview_mode = 0;
