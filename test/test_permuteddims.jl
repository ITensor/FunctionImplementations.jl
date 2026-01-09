import FunctionImplementations as FI
using Test: @test, @testset

@testset "permuteddims" begin
    a = randn(2, 3)
    b = FI.permuteddims(a, (2, 1))
    @test b ≡ PermutedDimsArray(a, (2, 1))
    @test size(b) == (3, 2)
    @test b == permutedims(a, (2, 1))
end
