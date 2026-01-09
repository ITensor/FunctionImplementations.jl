import FunctionImplementations as FI
import StridedViews as SV
using Test: @test, @testset

@testset "StridedViewsExt" begin
    a = SV.StridedView(randn(2, 3, 4))
    b = FI.permuteddims(a, (3, 2, 1))
    @test b isa SV.StridedView
    @test size(b) == (4, 3, 2)
    @test b ≡ permutedims(a, (3, 2, 1))
end