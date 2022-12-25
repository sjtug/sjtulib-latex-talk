# !/bin/bash
# Generate text and math font setup example.
# cambria: [Windows]

for textfont in {cambria,lm,newcm,newpx,newtx,stixtwo,times,xits}; do
    sed -e "s|<textfont>|$textfont|g" latinfont.ltx > latinfont-$textfont.tex
    latexmk -xelatex -interaction=nonstopmode latinfont-$textfont
done