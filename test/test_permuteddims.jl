import FillArrays as FA
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
    @testset "LinearAlgebra.Diagonal" begin
        a = LA.Diagonal(randn(3))
        b = FI.permuteddims(a, (2, 1))
        @test b ≡ a
    end

    @testset "FillArrays.RectDiagonal" begin
        a = FA.RectDiagonal(randn(3), (3, 4))
        @test FI.permuteddims(a, (1, 2)) ≡ a
        @test FI.permuteddims(a, (2, 1)) ≡ FA.RectDiagonal(parent(a), (4, 3))
    end
end
