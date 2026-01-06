using BlockArrays: BlockArray, blockedrange, blockisequal
using FunctionImplementations.Concatenate: concatenate
using Test: @test, @testset

@testset "BlockArraysExt" begin
    a = BlockArray(randn(4, 4), [2, 2], [2, 2])
    b = BlockArray(randn(4, 4), [2, 2], [2, 2])

    concat = concatenate(1, a, b)
    @test axes(concat) == (Base.OneTo(8), Base.OneTo(4))
    @test blockisequal(axes(concat, 1), blockedrange([2, 2, 2, 2]))
    @test blockisequal(axes(concat, 2), blockedrange([2, 2]))
    @test size(concat) == (8, 4)
    @test eltype(concat) ≡ Float64
    @test copy(concat) == cat(a, b; dims = 1)
    @test copy(concat) isa BlockArray{Float64, 2}
end
