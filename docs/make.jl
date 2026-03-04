using Documenter: Documenter, DocMeta, deploydocs, makedocs
using FunctionImplementations: FunctionImplementations
using ITensorFormatter: ITensorFormatter

DocMeta.setdocmeta!(
    FunctionImplementations, :DocTestSetup, :(using FunctionImplementations);
    recursive = true
)

ITensorFormatter.make_index!(pkgdir(FunctionImplementations))

makedocs(;
    modules = [FunctionImplementations],
    authors = "ITensor developers <support@itensor.org> and contributors",
    sitename = "FunctionImplementations.jl",
    format = Documenter.HTML(;
        canonical = "https://itensor.github.io/FunctionImplementations.jl",
        edit_link = "main",
        assets = ["assets/favicon.ico", "assets/extras.css"]
    ),
    pages = ["Home" => "index.md", "Reference" => "reference.md"]
)

deploydocs(;
    repo = "github.com/ITensor/FunctionImplementations.jl", devbranch = "main",
    push_preview = true
)
