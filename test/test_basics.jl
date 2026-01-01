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
    @testset "(s::Style)(f)" begin
        # Test the shorthand for creating an Implementation by calling a Style with a
        # function.
        @test FI.style([1, 2, 3])(getindex) ≡
            FI.Implementation(getindex, FI.DefaultArrayStyle())
    end
    @testset "Style" begin
        # Test basic Style trait for different array types
        @test FI.Style(typeof([1, 2, 3])) ≡ FI.DefaultArrayStyle()
        @test FI.style([1, 2, 3]) ≡ FI.DefaultArrayStyle()
        @test FI.Style(typeof([1 2; 3 4])) ≡ FI.DefaultArrayStyle()
        @test FI.Style(typeof(rand(2, 3, 4))) ≡ FI.DefaultArrayStyle()

        # Test custom Style definition
        struct CustomStyle <: FI.Style end
        struct CustomArray end
        FI.Style(::Type{CustomArray}) = CustomStyle()
        @test FI.Style(CustomArray) isa CustomStyle

        # Test custom AbstractArrayStyle definition
        struct MyArray{T, N} <: AbstractArray{T, N}
            data::Array{T, N}
        end
        struct MyArrayStyle <: FI.AbstractArrayStyle end
        FI.Style(::Type{<:MyArray}) = MyArrayStyle()
        @test FI.Style(MyArray) isa MyArrayStyle

        # Test style homogeneity rule (same type returns preserved)
        s1 = FI.DefaultArrayStyle()
        s2 = FI.DefaultArrayStyle()
        @test FI.Style(s1, s2) ≡ FI.DefaultArrayStyle()

        # Test UnknownStyle precedence
        unknown = FI.UnknownStyle()
        known = FI.DefaultArrayStyle()
        @test FI.Style(known, unknown) ≡ known
        @test FI.Style(unknown, unknown) ≡ unknown

        # Test ArrayConflict
        conflict = FI.ArrayConflict()
        @test conflict isa FI.ArrayConflict
        @test conflict isa FI.AbstractArrayStyle

        # Test style with no arguments
        @test FI.style() ≡ FI.DefaultArrayStyle()

        # Test style with single argument
        @test FI.style([1, 2]) ≡ FI.DefaultArrayStyle()
        @test FI.style([1 2; 3 4]) ≡ FI.DefaultArrayStyle()

        # Test style with two arguments
        result = FI.style([1, 2], [1 2; 3 4])
        @test result ≡ FI.DefaultArrayStyle()

        # Test style with same dimensions
        result = FI.style([1], [2])
        @test result ≡ FI.DefaultArrayStyle()

        # Test style with multiple arguments
        result = FI.style([1], [1 2], rand(2, 3, 4))
        @test result ≡ FI.DefaultArrayStyle()

        # Test result_style with single argument
        @test FI.result_style(FI.DefaultArrayStyle()) isa FI.DefaultArrayStyle

        # Test result_style with two identical styles
        s = FI.DefaultArrayStyle()
        @test FI.result_style(s, s) ≡ s

        # Test result_style with UnknownStyle
        known = FI.DefaultArrayStyle()
        unknown = FI.UnknownStyle()
        @test FI.result_style(known, unknown) ≡ known
        @test FI.result_style(unknown, known) ≡ known
    end
end
