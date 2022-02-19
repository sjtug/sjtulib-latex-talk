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

-- typseset_demo_tasks() start after support file copying
-- and before the main document is typeset.
function typeset_demo_tasks()
    local errorlevel = 0

    -- Refresh dependencies: SJTUBeamer, SJTUThesis
    local beamerdepdir = "SJTUBeamer"
    local thesisdepdir = "SJTUThesis"
    for _, dir in ipairs({beamerdepdir, thesisdepdir}) do
        if direxists(dir) == false then
            -- Clone the dependencies first.
            errorlevel = os.execute("git clone https://mirror.sjtu.edu.cn/git/" .. dir .. ".git/")
            if (errorlevel ~= 0) then 
                print("git clone " .. dir .. " failed")
                return errorlevel
            end
        else
            -- Update the dependencies.
            run(dir, "git pull")
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

    -- Compile the thesis on latexmk,
    -- since it is a custom compiling environment.
    local typesetthesisexe = "latexmk"
    -- Remember, although previous "git pull" 
    -- refreshed the tex file to default state,
    -- here we move the unchanged support files 
    -- to the dependency directory again 
    -- to overwrite the default files.
    local suppthesisdir = supportdir .. "/thesis"
    cp("*", suppthesisdir, thesisdepdir)
    local typesetthesisfiles = {"main.tex"} -- To be added "dev-v2.tex"
    for _, file in ipairs(typesetthesisfiles) do
        errorlevel = os.execute("cd " .. thesisdepdir .. " && " .. typesetthesisexe .. " " .. file)
        local pdffile = file:gsub("%.tex$", ".pdf")
        cp(pdffile, thesisdepdir, suppthesisdir)
        if (errorlevel ~= 0) then 
            print(typesetthesisexe .. " " .. file .. " failed")
            return errorlevel
        end
    end

    -- TODO: typeset auxiliary pdfs and cache them. Or use tikz. TBD.

    -- TODO: accelerate the compilation through etex.

    -- Rerun the support file copying,
    -- because the typesetsuppfiles is set to none
    -- in the first place and doesn't trigger the process.
    cp(supportdir, ".", typesetdir)

    return errorlevel
end