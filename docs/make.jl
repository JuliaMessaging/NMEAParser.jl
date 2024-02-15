push!(LOAD_PATH, "../src/")

using NMEAParser
using Documenter

DocMeta.setdocmeta!(NMEAParser, :DocTestSetup, :(using NMEAParser); recursive = true)

makedocs(;
    modules = [NMEAParser],
    authors = "Nicholas Shindler <nick@shindler.tech>",
    repo = "https://github.com/JuliaMessaging/NMEAParser.jl/blob/{commit}{path}#{line}",
    sitename = "NMEAParser.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaMessaging.github.io/NMEAParser.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)

deploydocs(; repo = "github.com/JuliaMessaging/NMEAParser.jl", devbranch = "main")
