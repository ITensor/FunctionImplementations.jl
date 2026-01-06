using Adapt: adapt
using FunctionImplementations.Concatenate: concatenated
using JLArrays: JLArray
using Test: @test, @testset

@testset "Concatenated" for arrayt in (Array, JLArray)
    dev = adapt(arrayt)
    a = dev(randn(Float32, 2, 2))
    b = dev(randn(Float64, 2, 2))

    concat = concatenated((1, 2), a, b)
    @test axes(concat) == Base.OneTo.((4, 4))
    @test size(concat) == (4, 4)
    @test eltype(concat) === Float64
    @test copy(concat) == cat(a, b; dims = (1, 2))
    @test copy(concat) isa arrayt{promote_type(eltype(a), eltype(b)), 2}

    concat = concatenated(1, a, b)
    @test axes(concat) == Base.OneTo.((4, 2))
    @test size(concat) == (4, 2)
    @test eltype(concat) === Float64
    @test copy(concat) == cat(a, b; dims = 1)
    @test copy(concat) isa arrayt{promote_type(eltype(a), eltype(b)), 2}

    concat = concatenated(3, a, b)
    @test axes(concat) == Base.OneTo.((2, 2, 2))
    @test size(concat) == (2, 2, 2)
    @test eltype(concat) === Float64
    @test copy(concat) == cat(a, b; dims = 3)
    @test copy(concat) isa arrayt{promote_type(eltype(a), eltype(b)), 3}

    concat = concatenated(4, a, b)
    @test axes(concat) == Base.OneTo.((2, 2, 1, 2))
    @test size(concat) == (2, 2, 1, 2)
    @test eltype(concat) === Float64
    @test copy(concat) == cat(a, b; dims = 4)
    @test copy(concat) isa arrayt{promote_type(eltype(a), eltype(b)), 4}
end
