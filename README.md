# 从零开始使用 LaTeX 排版论文

上海交通大学图书馆专题培训讲座 2022 年《从零开始使用 LaTeX 排版论文》。

第一次编译以及依赖文件更改后请使用
```
l3build doc
```
编译文件。

之后可以使用默认编译方法如 `latexmk` 编译主文件 `latex-talk.tex`。

需要上传到 Overleaf 编译请使用
```
l3build ctan
```
将生成的 `sjtulib-talk-ctan.zip` 上传，并使用 XeLaTeX 编译。

可以通过 [GitHub Issues](https://github.com/sjtug/sjtulib-latex-talk/issues) 报告文档中的 BUG 等。

以 CC BY-SA 4.0 协议许可。
