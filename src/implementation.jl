"""
`FunctionImplementations.Implementation(f, s)` wraps a function `f` with a style `s`.
This can be used to create function implementations that behave differently
based on the style of their arguments.
"""
struct Implementation{F, Style} <: Function
    f::F
    style::Style
end
