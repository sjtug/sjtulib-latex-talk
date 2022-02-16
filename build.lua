module       = "latex-talk"

docfiledir   = "."
typesetfiles = {"latex-talk-2022.tex"}

-- TODO: l3build doc will typeset the documentation.
-- TODO: hook the "l3build doc" method to ".vscode/settings.json"

function typeset_demo_tasks()
    local errorlevel = 0

    if fileexists("beamerthemesjtubeamer.sty") == false then
        -- Clone the theme first.
        errorlevel = os.execute("git clone https://mirror.sjtu.edu.cn/git/SJTUBeamer.git/")
        if (errorlevel ~= 0) then 
            print("git clone SJTUBeamer failed")
            return errorlevel
        end
        -- TODO: copy the theme to the current directory.
    end

    -- TODO: typeset pdfs and cache them. Or use tikz. TBD.

    -- TODO: accelerate the compilation throught etex.

    return errorlevel
end