import FunctionImplementations as FI
import LinearAlgebra as LA
using Test: @test, @testset

@testset "permuteddims" begin
    @testset "Array" begin
        a = randn(2, 3)
        b = FI.permuteddims(a, (2, 1))
        @test b ≡ PermutedDimsArray(a, (2, 1))
        @test size(b) == (3, 2)
        @test b == permutedims(a, (2, 1))
    end
    @testset "Diagonal" begin
        a = LA.Diagonal(randn(3))
        b = FI.permuteddims(a, (2, 1))
        @test b ≡ a
    end
end
