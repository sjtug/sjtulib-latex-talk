#!/usr/bin/env texlua

module       = "latex-talk"

docfiledir   = "."
typesetfiles = {"latex-talk-2022.tex"}

-- Select the typesetting engine for different platforms. 
if os.type == "windows" then
    typesetexe       = "pdflatex"
else
    typesetexe       = "xelatex"
end

supportdir = "support"

-- Compile the thesis on latexmk,
-- for a custom compiling environment typesetdir.
-- and copy the outpur pdf into outputdir.
function latexmk_typeset(file, typesetdir, outputdir)
    local latexmkexe = "latexmk"
    local latexmkopt = "-xelatex -interaction=nonstopmode"
    local errorlevel = os.execute("cd " .. typesetdir .. " && " 
        .. latexmkexe .. " " .. file .. " " .. latexmkopt)
    local pdffile = file:gsub("%.tex$", ".pdf")
    cp("main.pdf", typesetdir, outputdir)
    return errorlevel
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
    beamerdepreq = {"*.sty","contrib/","vi/"}
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
    errorlevel = latexmk_typeset("main.tex", thesisdepdir, suppthesisdir)
    if errorlevel ~= 0 then
        print("! latexmk main.tex failed")
        return errorlevel
    end

    -- Compile the thesis v2.
    -- Dependencies is at SJTUTeX, 
    -- generate the sty files by l3build convention
    -- for general compatibility over platforms.
    os.execute(
        "cd " .. thesisv2depdir .. "/sjtuthesis"
        .. " && " .. "l3build unpack")
    -- replace the old dependencies in SJTUThesis.
    cp("*", thesisv2depdir .. "/sjtuthesis/build/unpacked",
        thesisdepdir .. "/texmf/tex/latex/sjtuthesis")
    errorlevel = latexmk_typeset("dev-v2", thesisdepdir, suppthesisdir)
    if errorlevel ~= 0 then
        print("! latexmk dev-v2.tex failed")
        return errorlevel
    end

    -- TODO: typeset auxiliary pdfs and cache them. Or use tikz. TBD.

    -- TODO: accelerate the compilation through etex.

    -- Rerun the support file copying,
    -- because the typesetsuppfiles is set to none
    -- in the first place and doesn't trigger the process.
    cp(supportdir, ".", typesetdir)

    return errorlevel
end