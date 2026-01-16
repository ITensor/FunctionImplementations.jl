module FunctionImplementationsLinearAlgebraExt

import FunctionImplementations as FI
import LinearAlgebra as LA

struct DiagonalImplementationStyle <: FI.AbstractArrayImplementationStyle end
FI.ImplementationStyle(::Type{<:LA.Diagonal}) = DiagonalImplementationStyle()
const permuteddims_diag = DiagonalImplementationStyle()(FI.permuteddims)
function permuteddims_diag(a::AbstractArray, perm)
    (ndims(a) == length(perm) && isperm(perm)) ||
        throw(ArgumentError("no valid permutation of dimensions"))
    return a
end

end
