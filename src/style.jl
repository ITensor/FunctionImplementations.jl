### This is based on the BroadcastStyle code in
### https://github.com/JuliaLang/julia/blob/master/base/broadcast.jl
### Objects with customized behavior for a certain function should declare a Style

"""
`Style` is an abstract type and trait-function used to determine behavior of
objects. `Style(typeof(x))` returns the style associated
with `x`. To customize the behavior of a type, one can declare a style
by defining a type/method pair

    struct MyContainerStyle <: Style end
    FunctionImplementations.Style(::Type{<:MyContainer}) = MyContainerStyle()
    
"""
abstract type Style end
Style(::Type{T}) where {T} = throw(MethodError(Style, (T,)))

struct UnknownStyle <: Style end
Style(::Type{Union{}}, slurp...) = UnknownStyle()  # ambiguity resolution

"""
    (s::Style)(f)

Calling a Style `s` with a function `f` as `s(f)` is a shorthand for creating a
[`FunctionImplementations.Implementation`](@ref) object wrapping the function `f` with
Style `s`.
"""
(s::Style)(f) = Implementation(f, s)

"""
`FunctionImplementations.AbstractArrayStyle <: Style` is the abstract supertype for any style
associated with an `AbstractArray` type.

Note that if two or more `AbstractArrayStyle` subtypes conflict, the resulting
style will fall back to that of `Array`s. If this is undesirable, you may need to
define binary [`Style`](@ref) rules to control the output type.

See also [`FunctionImplementations.DefaultArrayStyle`](@ref).
"""
abstract type AbstractArrayStyle <: Style end

"""
`FunctionImplementations.DefaultArrayStyle()` is a [`FunctionImplementations.Style`](@ref)
indicating that an object behaves as an array. Specifically, `DefaultArrayStyle` is
used for any `AbstractArray` type that hasn't defined a specialized style, and in the
absence of overrides from other arguments the resulting output type is `Array`.
"""
struct DefaultArrayStyle <: AbstractArrayStyle end
Style(::Type{<:AbstractArray}) = DefaultArrayStyle()

# `ArrayConflict` is an internal type signaling that two or more different `AbstractArrayStyle`
# objects were supplied as arguments, and that no rule was defined for resolving the
# conflict. The resulting output is `Array`. While this is the same output type
# produced by `DefaultArrayStyle`, `ArrayConflict` "poisons" the Style so that
# 3 or more arguments still return an `ArrayConflict`.
struct ArrayConflict <: AbstractArrayStyle end

### Binary Style rules
"""
    Style(::Style1, ::Style2) = Style3()

Indicate how to resolve different `Style`s. For example,

    Style(::Primary, ::Secondary) = Primary()

would indicate that style `Primary` has precedence over `Secondary`.
You do not have to (and generally should not) define both argument orders.
The result does not have to be one of the input arguments, it could be a third type.
"""
Style(::S, ::S) where {S <: Style} = S() # homogeneous types preserved
# Fall back to UnknownStyle. This is necessary to implement argument-swapping
Style(::Style, ::Style) = UnknownStyle()
# UnknownStyle loses to everything
Style(::UnknownStyle, ::UnknownStyle) = UnknownStyle()
Style(::S, ::UnknownStyle) where {S <: Style} = S()
# Precedence rules
Style(::A, ::A) where {A <: AbstractArrayStyle} = A()
function Style(a::A, b::B) where {A <: AbstractArrayStyle, B <: AbstractArrayStyle}
    if Base.typename(A) ≡ Base.typename(B)
        return A()
    end
    return UnknownStyle()
end
# Any specific array type beats DefaultArrayStyle
Style(a::AbstractArrayStyle, ::DefaultArrayStyle) = a

## logic for deciding the Style

"""
    style(cs...)::Style

Decides which `Style` to use for any number of value arguments.
Uses [`Style`](@ref) to get the style for each argument, and uses
[`result_style`](@ref) to combine styles.

# Examples
```jldoctest
julia> FunctionImplementations.style([1], [1 2; 3 4])
FunctionImplementations.DefaultArrayStyle{Any}()
```
"""
function style end

style() = DefaultArrayStyle()
style(c) = result_style(Style(typeof(c)))
style(c1, c2) = result_style(style(c1), style(c2))
@inline style(c1, c2, cs...) = result_style(style(c1), style(c2, cs...))

"""
    result_style(s1::Style[, s2::Style])::Style

Takes one or two `Style`s and combines them using [`Style`](@ref) to
determine a common `Style`.

# Examples

```jldoctest
julia> FunctionImplementations.result_style(FunctionImplementations.DefaultArrayStyle(), FunctionImplementations.DefaultArrayStyle())
FunctionImplementations.DefaultArrayStyle()

julia> FunctionImplementations.result_style(FunctionImplementations.UnknownStyle(), FunctionImplementations.DefaultArrayStyle())
FunctionImplementations.DefaultArrayStyle()
```
"""
function result_style end

result_style(s::Style) = s
function result_style(s1::S, s2::S) where {S <: Style}
    return s1 ≡ s2 ? s1 : error("inconsistent styles, custom rule needed")
end
# Test both orders so users typically only have to declare one order
result_style(s1, s2) = result_join(s1, s2, Style(s1, s2), Style(s2, s1))

# result_join is the final arbiter. Because `Style` for undeclared pairs results in UnknownStyle,
# we defer to any case where the result of `Style` is known.
result_join(::Any, ::Any, ::UnknownStyle, ::UnknownStyle) = UnknownStyle()
result_join(::Any, ::Any, ::UnknownStyle, s::Style) = s
result_join(::Any, ::Any, s::Style, ::UnknownStyle) = s
# For AbstractArray types with undefined precedence rules,
# we have to signal conflict. Because ArrayConflict is a subtype of AbstractArray,
# this will "poison" any future operations (if we instead returned `DefaultArrayStyle`, then for
# 3-array functions returned type would depend on argument order).
result_join(::AbstractArrayStyle, ::AbstractArrayStyle, ::UnknownStyle, ::UnknownStyle) =
    ArrayConflict()
# Fallbacks in case users define `rule` for both argument-orders (not recommended)
result_join(::Any, ::Any, s1::S, s2::S) where {S <: Style} = result_style(s1, s2)

@noinline function result_join(::S, ::T, ::U, ::V) where {S, T, U, V}
    error(
        """
        conflicting rules defined
          FunctionImplementations.Style(::$S, ::$T) = $U()
          FunctionImplementations.Style(::$T, ::$S) = $V()
        One of these should be undefined (and thus return FunctionImplementations.UnknownStyle)."""
    )
end
