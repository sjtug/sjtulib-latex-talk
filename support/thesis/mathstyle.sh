# !/bin/bash
# Generate mathstyle example.

for mathstyle in {ISO,TeX}; do
    sed -e "s|<mathstyle>|$mathstyle|g" mathstyle.ltx > mathstyle-$mathstyle.tex
    latexmk -xelatex -interaction=nonstopmode mathstyle-$mathstyle
done