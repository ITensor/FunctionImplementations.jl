using FunctionImplementations: FunctionImplementations
using Documenter: Documenter, DocMeta, deploydocs, makedocs

DocMeta.setdocmeta!(
    FunctionImplementations, :DocTestSetup, :(using FunctionImplementations); recursive = true
)

include("make_index.jl")

makedocs(;
    modules = [FunctionImplementations],
    authors = "ITensor developers <support@itensor.org> and contributors",
    sitename = "FunctionImplementations.jl",
    format = Documenter.HTML(;
        canonical = "https://itensor.github.io/FunctionImplementations.jl",
        edit_link = "main",
        assets = ["assets/favicon.ico", "assets/extras.css"],
    ),
    pages = ["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(;
    repo = "github.com/ITensor/FunctionImplementations.jl", devbranch = "main", push_preview = true
)
