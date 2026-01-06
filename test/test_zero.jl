using FunctionImplementations: zero!
using Test: @test, @testset

@testset "zero!" begin
    a = randn(2, 2)
    zero!(a)
    @test iszero(a)
end
