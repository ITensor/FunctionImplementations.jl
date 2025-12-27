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
        @test FI.Style([1, 2, 3])(getindex) ≡
            FI.Implementation(getindex, FI.DefaultArrayStyle{1}())
    end
    @testset "Style" begin
        # Test basic Style trait for different array types
        @test FI.Style(typeof([1, 2, 3])) isa FI.DefaultArrayStyle{1}
        @test FI.Style([1, 2, 3]) isa FI.DefaultArrayStyle{1}
        @test FI.Style(typeof([1 2; 3 4])) isa FI.DefaultArrayStyle{2}
        @test FI.Style(typeof(rand(2, 3, 4))) isa FI.DefaultArrayStyle{3}

        # Test custom Style definition
        struct CustomStyle <: FI.Style end
        struct CustomArray end
        FI.Style(::Type{CustomArray}) = CustomStyle()
        @test FI.Style(CustomArray) isa CustomStyle

        # Test custom AbstractArrayStyle definition
        struct MyArray{T, N} <: AbstractArray{T, N}
            data::Array{T, N}
        end
        struct MyArrayStyle <: FI.AbstractArrayStyle{Any} end
        FI.Style(::Type{<:MyArray}) = MyArrayStyle()
        @test FI.Style(MyArray) isa MyArrayStyle

        # Test style homogeneity rule (same type returns preserved)
        s1 = FI.DefaultArrayStyle{1}()
        s2 = FI.DefaultArrayStyle{1}()
        @test FI.Style(s1, s2) ≡ s1

        # Test UnknownStyle precedence
        unknown = FI.UnknownStyle()
        known = FI.DefaultArrayStyle{1}()
        @test FI.Style(known, unknown) ≡ known
        @test FI.Style(unknown, unknown) ≡ unknown

        # Test AbstractArrayStyle with different dimensions uses max
        @test FI.Style(
            FI.DefaultArrayStyle{1}(),
            FI.DefaultArrayStyle{2}()
        ) isa FI.DefaultArrayStyle{Any}

        # Test DefaultArrayStyle Val constructor preserves type when dimension matches
        default_style = FI.DefaultArrayStyle{1}(Val(1))
        @test FI.DefaultArrayStyle{1}(Val(1)) isa FI.DefaultArrayStyle{1}

        # Test DefaultArrayStyle Val constructor changes dimension
        @test FI.DefaultArrayStyle{1}(Val(2)) isa FI.DefaultArrayStyle{2}

        # Test DefaultArrayStyle constructor defaults to Any dimension
        @test FI.DefaultArrayStyle() isa FI.DefaultArrayStyle{Any}

        # Test const aliases
        @test FI.DefaultVectorStyle ≡ FI.DefaultArrayStyle{1}
        @test FI.DefaultMatrixStyle ≡ FI.DefaultArrayStyle{2}

        # Test ArrayConflict
        conflict = FI.ArrayConflict()
        @test conflict isa FI.ArrayConflict
        @test conflict isa FI.AbstractArrayStyle{Any}

        # Test ArrayConflict Val constructor
        conflict_val = FI.ArrayConflict(Val(3))
        @test conflict_val isa FI.ArrayConflict

        # Test combine_styles with no arguments
        @test FI.combine_styles() isa FI.DefaultArrayStyle{0}

        # Test combine_styles with single argument
        @test FI.combine_styles([1, 2]) isa FI.DefaultArrayStyle{1}
        @test FI.combine_styles([1 2; 3 4]) isa FI.DefaultArrayStyle{2}

        # Test combine_styles with two arguments
        result = FI.combine_styles([1, 2], [1 2; 3 4])
        @test result isa FI.DefaultArrayStyle{Any}

        # Test combine_styles with same dimensions
        result = FI.combine_styles([1], [2])
        @test result isa FI.DefaultArrayStyle{1}

        # Test combine_styles with multiple arguments
        result = FI.combine_styles([1], [1 2], rand(2, 3, 4))
        @test result isa FI.DefaultArrayStyle{Any}

        # Test result_style with single argument
        @test FI.result_style(FI.DefaultArrayStyle{1}()) isa FI.DefaultArrayStyle{1}

        # Test result_style with two identical styles
        s = FI.DefaultArrayStyle{2}()
        @test FI.result_style(s, s) ≡ s

        # Test result_style with UnknownStyle
        known = FI.DefaultArrayStyle{1}()
        unknown = FI.UnknownStyle()
        @test FI.result_style(known, unknown) ≡ known
        @test FI.result_style(unknown, known) ≡ known

        # Test result_style with different dimension DefaultArrayStyle uses max
        result = FI.result_style(
            FI.DefaultArrayStyle{1}(),
            FI.DefaultArrayStyle{2}()
        )
        @test result isa FI.DefaultArrayStyle{Any}

        # Test result_style with same shape behaves consistently
        same_style = FI.DefaultArrayStyle{2}()
        @test FI.result_style(same_style, same_style) ≡ same_style
    end
end
