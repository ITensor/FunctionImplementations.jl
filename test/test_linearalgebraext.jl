import FunctionImplementations as FI
import LinearAlgebra as LA
using Test: @test, @testset

@testset "LinearAlgebraExt" begin
    a = LA.Diagonal(randn(3))
    b = FI.permuteddims(a, (2, 1))
    @test b ≡ a
end
