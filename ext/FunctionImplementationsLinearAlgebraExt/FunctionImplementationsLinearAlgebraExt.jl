module FunctionImplementationsLinearAlgebraExt

import FunctionImplementations as FI
import LinearAlgebra as LA

struct DiagonalStyle <: FI.AbstractMatrixStyle end
FI.Style(::Type{<:LA.Diagonal}) = DiagonalStyle()
const permuteddims_diag = FI.Implementation(FI.permuteddims, DiagonalStyle())
function permuteddims_diag(a::AbstractArray, perm)
    (ndims(a) == length(perm) && isperm(perm)) ||
        throw(ArgumentError("no valid permutation of dimensions"))
    return a
end

end
