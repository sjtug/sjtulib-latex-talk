# 如何使用 LaTeX 排版论文/幻灯片

上海交通大学图书馆专题培训讲座 2022 年《从零开始使用 LaTeX 排版论文》与《如何使用 beamer 制作学术报告幻灯片》。

### 第一次编译

第一次编译以及依赖文件更改后请使用
```
l3build doc
```
编译文件。

### 编辑时编译

之后可以使用默认编译方法如 `latexmk` 编译主文件 `latex-talk.tex`。

### 上传至 Overleaf

需要上传到 Overleaf 编译请使用
```
l3build ctan
```
将生成的 `sjtulib-talk-ctan.zip` 上传，并使用 XeLaTeX 编译。受 Overleaf 编译时长限制，目前可以在[这个链接](https://www.overleaf.com/read/fvwxzvcxhcwd)上看到最近一次讲座的内容。可以下载预编译的 Overleaf 版本，在 `latex-talk.tex` 主文件中选择需要编译哪些部分后，手动本地编译全部内容。

### 预编译版本

也可以在[此处](https://github.com/sjtug/sharing/tree/master/2022-05-18)得到预编译的 PDF 文件。

### 贡献/许可

可以通过 [GitHub Issues](https://github.com/sjtug/sjtulib-latex-talk/issues) 报告文档中的 BUG 等。

以 CC BY-SA 4.0 协议许可。
