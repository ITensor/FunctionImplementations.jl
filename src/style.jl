### This is based on the BroadcastStyle code in
### https://github.com/JuliaLang/julia/blob/master/base/broadcast.jl
### Objects with customized behavior for a certain function should declare a ImplementationStyle

"""
`ImplementationStyle` is an abstract type and trait-function used to determine behavior of
objects. `ImplementationStyle(typeof(x))` returns the style associated
with `x`. To customize the behavior of a type, one can declare a style
by defining a type/method pair

    struct MyContainerImplementationStyle <: ImplementationStyle end
    FunctionImplementations.ImplementationStyle(::Type{<:MyContainer}) = MyContainerImplementationStyle()
"""
abstract type ImplementationStyle end
ImplementationStyle(::Type{T}) where {T} = throw(MethodError(ImplementationStyle, (T,)))

struct UnknownImplementationStyle <: ImplementationStyle end
ImplementationStyle(::Type{Union{}}, slurp...) = UnknownImplementationStyle()  # ambiguity resolution

"""
    (s::ImplementationStyle)(f)

Calling a ImplementationStyle `s` with a function `f` as `s(f)` is a shorthand for creating a
[`FunctionImplementations.Implementation`](@ref) object wrapping the function `f` with
ImplementationStyle `s`.
"""
(s::ImplementationStyle)(f) = Implementation(f, s)

"""
`FunctionImplementations.AbstractArrayImplementationStyle <: ImplementationStyle` is the abstract supertype for any style
associated with an `AbstractArray` type.

Note that if two or more `AbstractArrayImplementationStyle` subtypes conflict, the resulting
style will fall back to that of `Array`s. If this is undesirable, you may need to
define binary [`ImplementationStyle`](@ref) rules to control the output type.

See also [`FunctionImplementations.DefaultArrayImplementationStyle`](@ref).
"""
abstract type AbstractArrayImplementationStyle <: ImplementationStyle end

"""
`FunctionImplementations.DefaultArrayImplementationStyle()` is a [`FunctionImplementations.ImplementationStyle`](@ref)
indicating that an object behaves as an array. Specifically, `DefaultArrayImplementationStyle` is
used for any `AbstractArray` type that hasn't defined a specialized style, and in the
absence of overrides from other arguments the resulting output type is `Array`.
"""
struct DefaultArrayImplementationStyle <: AbstractArrayImplementationStyle end
ImplementationStyle(::Type{<:AbstractArray}) = DefaultArrayImplementationStyle()

# `ArrayImplementationConflict` is an internal type signaling that two or more different `AbstractArrayImplementationStyle`
# objects were supplied as arguments, and that no rule was defined for resolving the
# conflict. The resulting output is `Array`. While this is the same output type
# produced by `DefaultArrayImplementationStyle`, `ArrayImplementationConflict` "poisons" the ImplementationStyle so that
# 3 or more arguments still return an `ArrayImplementationConflict`.
struct ArrayImplementationConflict <: AbstractArrayImplementationStyle end

### Binary ImplementationStyle rules
"""
    ImplementationStyle(::ImplementationStyle1, ::ImplementationStyle2) = ImplementationStyle3()

Indicate how to resolve different `ImplementationStyle`s. For example,

    ImplementationStyle(::Primary, ::Secondary) = Primary()

would indicate that style `Primary` has precedence over `Secondary`.
You do not have to (and generally should not) define both argument orders.
The result does not have to be one of the input arguments, it could be a third type.
"""
ImplementationStyle(::S, ::S) where {S <: ImplementationStyle} = S() # homogeneous types preserved
# Fall back to UnknownImplementationStyle. This is necessary to implement argument-swapping
function ImplementationStyle(::ImplementationStyle, ::ImplementationStyle)
    return UnknownImplementationStyle()
end
# UnknownImplementationStyle loses to everything
function ImplementationStyle(::UnknownImplementationStyle, ::UnknownImplementationStyle)
    return UnknownImplementationStyle()
end
function ImplementationStyle(
        ::S,
        ::UnknownImplementationStyle
    ) where {S <: ImplementationStyle}
    return S()
end
# Precedence rules
ImplementationStyle(::A, ::A) where {A <: AbstractArrayImplementationStyle} = A()
function ImplementationStyle(
        a::A,
        b::B
    ) where {A <: AbstractArrayImplementationStyle, B <: AbstractArrayImplementationStyle}
    if Base.typename(A) ≡ Base.typename(B)
        return A()
    end
    return UnknownImplementationStyle()
end
# Any specific array type beats DefaultArrayImplementationStyle
function ImplementationStyle(
        a::AbstractArrayImplementationStyle,
        ::DefaultArrayImplementationStyle
    )
    return a
end

## logic for deciding the ImplementationStyle

"""
    style(cs...)::ImplementationStyle

Decides which `ImplementationStyle` to use for any number of value arguments.
Uses [`ImplementationStyle`](@ref) to get the style for each argument, and uses
[`result_style`](@ref) to combine styles.

# Examples

```jldoctest
julia> FunctionImplementations.style([1], [1 2; 3 4])
FunctionImplementations.DefaultArrayImplementationStyle()
```
"""
function style end

style() = DefaultArrayImplementationStyle()
style(c) = result_style(ImplementationStyle(typeof(c)))
style(c1, c2) = result_style(style(c1), style(c2))
@inline style(c1, c2, cs...) = result_style(style(c1), style(c2, cs...))

"""
    result_style(s1::ImplementationStyle[, s2::ImplementationStyle])::ImplementationStyle

Takes one or two `ImplementationStyle`s and combines them using [`ImplementationStyle`](@ref) to
determine a common `ImplementationStyle`.

# Examples

```jldoctest
julia> FunctionImplementations.result_style(
           FunctionImplementations.DefaultArrayImplementationStyle(),
           FunctionImplementations.DefaultArrayImplementationStyle()
       )
FunctionImplementations.DefaultArrayImplementationStyle()

julia> FunctionImplementations.result_style(
           FunctionImplementations.UnknownImplementationStyle(),
           FunctionImplementations.DefaultArrayImplementationStyle()
       )
FunctionImplementations.DefaultArrayImplementationStyle()
```
"""
function result_style end

result_style(s::ImplementationStyle) = s
function result_style(s1::S, s2::S) where {S <: ImplementationStyle}
    return s1 ≡ s2 ? s1 : error("inconsistent styles, custom rule needed")
end
# Test both orders so users typically only have to declare one order
function result_style(s1, s2)
    return result_join(s1, s2, ImplementationStyle(s1, s2), ImplementationStyle(s2, s1))
end

# result_join is the final arbiter. Because `ImplementationStyle` for undeclared pairs results in UnknownImplementationStyle,
# we defer to any case where the result of `ImplementationStyle` is known.
function result_join(
        ::Any,
        ::Any,
        ::UnknownImplementationStyle,
        ::UnknownImplementationStyle
    )
    return UnknownImplementationStyle()
end
result_join(::Any, ::Any, ::UnknownImplementationStyle, s::ImplementationStyle) = s
result_join(::Any, ::Any, s::ImplementationStyle, ::UnknownImplementationStyle) = s
# For AbstractArray types with undefined precedence rules,
# we have to signal conflict. Because ArrayImplementationConflict is a subtype of AbstractArray,
# this will "poison" any future operations (if we instead returned `DefaultArrayImplementationStyle`, then for
# 3-array functions returned type would depend on argument order).
function result_join(
        ::AbstractArrayImplementationStyle,
        ::AbstractArrayImplementationStyle,
        ::UnknownImplementationStyle,
        ::UnknownImplementationStyle
    )
    return ArrayImplementationConflict()
end
# Fallbacks in case users define `rule` for both argument-orders (not recommended)
function result_join(::Any, ::Any, s1::S, s2::S) where {S <: ImplementationStyle}
    return result_style(s1, s2)
end

@noinline function result_join(::S, ::T, ::U, ::V) where {S, T, U, V}
    return error(
        """
        conflicting rules defined
          FunctionImplementations.ImplementationStyle(::$S, ::$T) = $U()
          FunctionImplementations.ImplementationStyle(::$T, ::$S) = $V()
        One of these should be undefined (and thus return FunctionImplementations.UnknownImplementationStyle)."""
    )
end
