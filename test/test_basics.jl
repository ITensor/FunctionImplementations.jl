import FunctionImplementations as FI
using Test: @test, @testset

@testset "FunctionImplementations" begin
    @testset "Implementation" begin
        struct MyAddAlgorithm end
        f = FI.Implementation(+, MyAddAlgorithm())
        @test f.f ≡ +
        @test f.style ≡ MyAddAlgorithm()
        (::typeof(f))(x, y) = "My add"
        @test f(2, 3) == "My add"
        @test f.f ≡ +
        @test f.style ≡ MyAddAlgorithm()
    end
    @testset "Style" begin
    end
end
