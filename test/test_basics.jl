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
    @testset "(s::ImplementationStyle)(f)" begin
        # Test the shorthand for creating an Implementation by calling a ImplementationStyle with a
        # function.
        @test FI.style([1, 2, 3])(getindex) ≡
            FI.Implementation(getindex, FI.DefaultArrayImplementationStyle())
    end
    @testset "ImplementationStyle" begin
        # Test basic ImplementationStyle trait for different array types
        @test FI.ImplementationStyle(typeof([1, 2, 3])) ≡
            FI.DefaultArrayImplementationStyle()
        @test FI.style([1, 2, 3]) ≡ FI.DefaultArrayImplementationStyle()
        @test FI.ImplementationStyle(typeof([1 2; 3 4])) ≡
            FI.DefaultArrayImplementationStyle()
        @test FI.ImplementationStyle(typeof(rand(2, 3, 4))) ≡
            FI.DefaultArrayImplementationStyle()

        # Test custom ImplementationStyle definition
        struct CustomImplementationStyle <: FI.ImplementationStyle end
        struct CustomArray end
        FI.ImplementationStyle(::Type{CustomArray}) = CustomImplementationStyle()
        @test FI.ImplementationStyle(CustomArray) isa CustomImplementationStyle

        # Test custom AbstractArrayImplementationStyle definition
        struct MyArray{T, N} <: AbstractArray{T, N}
            data::Array{T, N}
        end
        struct MyArrayImplementationStyle <: FI.AbstractArrayImplementationStyle end
        FI.ImplementationStyle(::Type{<:MyArray}) = MyArrayImplementationStyle()
        @test FI.ImplementationStyle(MyArray) isa MyArrayImplementationStyle

        # Test style homogeneity rule (same type returns preserved)
        s1 = FI.DefaultArrayImplementationStyle()
        s2 = FI.DefaultArrayImplementationStyle()
        @test FI.ImplementationStyle(s1, s2) ≡ FI.DefaultArrayImplementationStyle()

        # Test UnknownImplementationStyle precedence
        unknown = FI.UnknownImplementationStyle()
        known = FI.DefaultArrayImplementationStyle()
        @test FI.ImplementationStyle(known, unknown) ≡ known
        @test FI.ImplementationStyle(unknown, unknown) ≡ unknown

        # Test ArrayImplementationConflict
        conflict = FI.ArrayImplementationConflict()
        @test conflict isa FI.ArrayImplementationConflict
        @test conflict isa FI.AbstractArrayImplementationStyle

        # Test style with no arguments
        @test FI.style() ≡ FI.DefaultArrayImplementationStyle()

        # Test style with single argument
        @test FI.style([1, 2]) ≡ FI.DefaultArrayImplementationStyle()
        @test FI.style([1 2; 3 4]) ≡ FI.DefaultArrayImplementationStyle()

        # Test style with two arguments
        result = FI.style([1, 2], [1 2; 3 4])
        @test result ≡ FI.DefaultArrayImplementationStyle()

        # Test style with same dimensions
        result = FI.style([1], [2])
        @test result ≡ FI.DefaultArrayImplementationStyle()

        # Test style with multiple arguments
        result = FI.style([1], [1 2], rand(2, 3, 4))
        @test result ≡ FI.DefaultArrayImplementationStyle()

        # Test result_style with single argument
        @test FI.result_style(FI.DefaultArrayImplementationStyle()) isa
            FI.DefaultArrayImplementationStyle

        # Test result_style with two identical styles
        s = FI.DefaultArrayImplementationStyle()
        @test FI.result_style(s, s) ≡ s

        # Test result_style with UnknownImplementationStyle
        known = FI.DefaultArrayImplementationStyle()
        unknown = FI.UnknownImplementationStyle()
        @test FI.result_style(known, unknown) ≡ known
        @test FI.result_style(unknown, known) ≡ known
    end
end
