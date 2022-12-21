\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\ProvidesClass{myart}[2022/12/28 v1.0 My]
\DeclareOption{sjtu}{\def\school{SJTU}}
\DeclareOption{fdu}{\def\school{FDU}}
\ExecuteOptions{fdu}
\ProcessOptions*
\LoadClass{article}
\newcommand{\mycmd}[1]{#1 in \school}
\PassOptionsToPackage{\school}{myother}
\RequirePackage{myother}
\othercmd % provided by myother