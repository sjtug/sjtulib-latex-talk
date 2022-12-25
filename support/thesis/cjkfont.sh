# !/bin/bash
# Generate CJK font setup example.
# adobe: install one of the Adobe's software
# fandol: included in TeX Live
# founder: download from www.foundertype.com
# mac: [macOS]
# ubuntu: [Ubuntu]
# windows: [Windows]

for cjkfont in {adobe,fandol,founder,mac,ubuntu,windows}; do
    sed -e "s|<cjkfont>|$cjkfont|g" cjkfont.ltx > cjkfont-$cjkfont.tex
    latexmk -xelatex -interaction=nonstopmode cjkfont-$cjkfont
done