module FunctionImplementationsFillArraysExt

using FillArrays: RectDiagonal
using FunctionImplementations: FunctionImplementations

function FunctionImplementations.permuteddims(a::RectDiagonal, perm)
  (ndims(a) == length(perm) && isperm(perm)) ||
    throw(ArgumentError("no valid permutation of dimensions"))
  return RectDiagonal(parent(a), ntuple(d -> axes(a)[perm[d]], ndims(a)))
end

end
