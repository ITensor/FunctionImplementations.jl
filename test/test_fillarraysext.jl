import FillArrays as FA
import FunctionImplementations as FI
using Test: @test, @testset

@testset "FillArraysExt" begin
    @testset "Fill" begin
        a = FA.Fill(42, (2, 3))
        @test FI.permuteddims(a, (1, 2)) ≡ a
        @test FI.permuteddims(a, (2, 1)) ≡ FA.Fill(42, (3, 2))
    end
    @testset "Zeros" begin
        a = FA.Zeros((2, 3))
        @test FI.permuteddims(a, (1, 2)) ≡ a
        @test FI.permuteddims(a, (2, 1)) ≡ FA.Zeros((3, 2))
    end
    @testset "Ones" begin
        a = FA.Ones((2, 3))
        @test FI.permuteddims(a, (1, 2)) ≡ a
        @test FI.permuteddims(a, (2, 1)) ≡ FA.Ones((3, 2))
    end
    @testset "RectDiagonal" begin
        a = FA.RectDiagonal(randn(3), (3, 4))
        @test FI.permuteddims(a, (1, 2)) ≡ a
        @test FI.permuteddims(a, (2, 1)) ≡ FA.RectDiagonal(parent(a), (4, 3))
    end
end
