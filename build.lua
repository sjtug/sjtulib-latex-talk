#!/usr/bin/env texlua

module       = "latex-talk"

docfiledir   = "."
typesetfiles = {"latex-talk.tex"}
typesetopts  = "-interaction=nonstopmode -shell-escape"

-- Package for Overleaf
sourcedir    = "."
sourcefiles = {"*.sty","vi/","contrib/","support/"}

-- Select the typesetting engine for different platforms.
if os.type == "windows" then
    typesetexe       = "pdflatex"
    etypesetexe      = "etex"
else
    typesetexe       = "xelatex"
    etypesetexe      = "xetex"
end

supportdir = "support"

-- Compile on latexmk,
-- for a custom compiling environment typesetdir.
-- and copy the output pdf into outputdir.
function latexmk_typeset(file, typesetdir, outputdir)
    local latexmkexe = "latexmk"
    local latexmkopt = "-xelatex -interaction=nonstopmode -shell-escape"
    local errorlevel = os.execute("cd " .. typesetdir .. " && " 
        .. latexmkexe .. " " .. file .. " " .. latexmkopt)
    local pdffile = file:gsub("%.tex$", ".pdf")
    cp(pdffile, typesetdir, outputdir)
    return errorlevel
end

-- typeset all the tex files in dir.
function typesetdirtex(dir)
    for _, file in ipairs(filelist(dir, "*.tex")) do
        if fileexists(dir .. "/" .. file:gsub("%.tex$", ".pdf")) == false then
            errorlevel = latexmk_typeset(file, dir, dir)
            if errorlevel ~= 0 then
                print("! latexmk " .. file .. " failed")
                return errorlevel
            end
        end
    end
    return 0
end

-- typseset_demo_tasks() start after support file copying
-- and before the main document is typeset.
function typeset_demo_tasks()
    local errorlevel = 0

    -- Refresh dependencies: SJTUBeamer, SJTUThesis, SJTUTeX
    local beamerdepdir = "SJTUBeamer"
    local thesisdepdir = "SJTUThesis"
    local thesisv2depdir = "SJTUTeX"
    for _, dir in ipairs({beamerdepdir, thesisdepdir, thesisv2depdir}) do
        if direxists(dir) == false then
            -- Clone the dependencies first.
            errorlevel = os.execute("git clone https://mirror.sjtu.edu.cn/git/" .. dir .. ".git/")
            if (errorlevel ~= 0) then 
                print("! git clone " .. dir .. " failed")
                return errorlevel
            end
        else
            -- Update the dependencies from the master branch 
            -- and reset to the current state forcely.
            os.execute("cd " .. dir ..
                " && git fetch && git reset --hard && git pull")
        end
    end

    -- Required files in SJTUBeamer.
    local beamerdepreq = {"*.sty","contrib/","vi/",".vscode/"}
    -- Move the required dependencies to the current folder
    -- for compatibility with overleaf version.
    -- and to the doc build directory for l3build typesetting.
    for _, file in pairs(beamerdepreq) do
        cp(file, beamerdepdir, docfiledir)
        cp(file, beamerdepdir, typesetdir)
    end

    -- Remember, although previous "git pull" 
    -- refreshed the tex file to default state,
    -- here we move the unchanged support files 
    -- to the dependency directory again 
    -- to overwrite the default files.
    local suppthesisdir = supportdir .. "/thesis"
    cp("*", suppthesisdir, thesisdepdir)

    -- WARNING: When thesis v1 is deprecated,
    --          you should just compile main.tex only.

    -- Compile the thesis v1 first.
    for _, file in ipairs({"bachelor.tex", "master.tex", "doctor.tex", "course.tex", "main.tex"}) do
        errorlevel = latexmk_typeset(file, thesisdepdir, suppthesisdir)
        if errorlevel ~= 0 then
            print("! latexmk " .. file .. " failed")
            return errorlevel
        end
    end

    -- Compile the thesis v2.
    -- Dependencies is at SJTUTeX, 
    -- generate the sty files by l3build convention
    -- for general compatibility over platforms.
    os.execute(
        "cd " .. thesisv2depdir .. "/sjtuthesis"
        .. " && " .. "l3build unpack")
    -- replace the old dependencies in SJTUThesis.
    rm("*", thesisdepdir .. "/texmf/tex/latex/sjtuthesis")
    cp("*", thesisv2depdir .. "/sjtuthesis/build/unpacked",
        thesisdepdir .. "/texmf/tex/latex/sjtuthesis")
    errorlevel = latexmk_typeset("dev-v2", thesisdepdir, suppthesisdir)
    if errorlevel ~= 0 then
        print("! latexmk dev-v2.tex failed")
        print("+ Try updating the newtx package to 2022/01/12 (1.7) and later.")
        errorlevel = os.execute("tlmgr update newtx")   -- Might not be useful for MiKTeX distribution.
        errorlevel = errorlevel + latexmk_typeset("dev-v2", thesisdepdir, suppthesisdir)
        if errorlevel ~= 0 then
            print("  Or stay tuned for TeX Live 2022.")
            return errorlevel
        end
    end

    local suppbeamerdir = supportdir .. "/beamer"
    cp("*", suppbeamerdir, beamerdepdir)
    for _, file in ipairs({"hello.tex"}) do
        errorlevel = latexmk_typeset(file, beamerdepdir, suppbeamerdir)
        if errorlevel ~= 0 then
            print("! latexmk " .. file .. " failed")
            return errorlevel
        end
    end

    -- typeset auxiliary pdfs and cache them.
    local auxdirs = {
        supportdir .. "/examples",
        suppthesisdir .. "/figures"
    }
    for _, dir in ipairs(auxdirs) do
        errorlevel = typesetdirtex(dir)
        if errorlevel ~= 0 then
            return errorlevel
        end
    end

    -- TODO: accelerate the compilation through etex.
    -- for _, file in ipairs(typesetfiles) do
    --     local etypesetcommand = etypesetexe .. "  -ini -interaction=nonstopmode -jobname=" .. file:gsub("%.tex$", ".pdf") .. " \"&" .. typesetexe .. "\" mylatexformat.ltx "
    --     errorlevel = tex("\"\"\"" .. file .. "\"\"\"", ".", etypesetcommand)
    -- end

    -- clean up the auxiliary files.
    cleandirs = {
        supportdir .. "/contents",
        supportdir .. "/examples",
        supportdir .. "/figures",
        supportdir .. "/thesis"
    }
    cleansuffixs = {
        ".aux",
        ".fdb_latexmk",
        ".fls",
        ".log",
        ".synctex.gz",
        ".nav",
        ".snm",
        ".toc",
        ".out"
    }
    for _, dir in ipairs(cleandirs) do
        for _, suffix in ipairs(cleansuffixs) do
            rm(dir, "*" .. suffix)
        end
    end

    -- Rerun the support file copying,
    -- because the typesetsuppfiles is set to none
    -- in the first place and doesn't trigger the process.
    cp(supportdir, ".", typesetdir)

    return errorlevel
end