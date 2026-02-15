module FunctionImplementationsFillArraysExt

import FunctionImplementations as FI
using FillArrays: FillArrays as FA, AbstractFill, RectDiagonal

function check_perm(a::AbstractArray, perm)
    (ndims(a) == length(perm) && isperm(perm)) ||
        throw(ArgumentError("no valid permutation of dimensions"))
    return nothing
end

function perm_axes(a::AbstractArray, perm)
    return ntuple(d -> axes(a)[perm[d]], ndims(a))
end

# This could call `permutedims` directly after
# https://github.com/JuliaArrays/FillArrays.jl/pull/319 is merged.
function FI.permuteddims(a::AbstractFill, perm)
    check_perm(a, perm)
    return FA.fillsimilar(parent(a), perm_axes(a, perm))
end

# This could call `permutedims` directly after
# https://github.com/JuliaArrays/FillArrays.jl/issues/413 is fixed.
function FI.permuteddims(a::RectDiagonal, perm)
    check_perm(a, perm)
    return RectDiagonal(parent(a), perm_axes(a, perm))
end

end
