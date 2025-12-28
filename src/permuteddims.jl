# See: https://github.com/JuliaLang/julia/issues/53188
"""
    permuteddims(a::AbstractArray, perm)

Lazy version of `permutedims`. Defaults to constructing a `Base.PermutedDimsArray`
but can be customized to output a different type of array.
"""
permuteddims(a::AbstractArray, perm) = style(a)(permuteddims)(a, perm)
function (::Implementation{typeof(permuteddims)})(a::AbstractArray, perm)
    return PermutedDimsArray(a, perm)
end
