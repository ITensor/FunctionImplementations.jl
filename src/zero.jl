"""
    zero!(a::AbstractArray)

In-place version of `zero(a)`, sets all entries of `a` to zero.
"""
zero!(a::AbstractArray) = style(a)(zero!)(a)
function (::Implementation{typeof(zero!)})(a::AbstractArray)
    fill!(a, zero(eltype(a)))
    return a
end
