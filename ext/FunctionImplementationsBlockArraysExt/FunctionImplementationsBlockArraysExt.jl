module FunctionImplementationsBlockArraysExt

using BlockArrays: AbstractBlockedUnitRange, blockedrange, blocklengths
using FunctionImplementations.Concatenate: Concatenate

function Concatenate.cat_axis(a1::AbstractBlockedUnitRange, a2::AbstractBlockedUnitRange)
    first(a1) == first(a2) == 1 || throw(ArgumentError("Concatenated axes must start at 1"))
    return blockedrange([blocklengths(a1); blocklengths(a2)])
end

end
