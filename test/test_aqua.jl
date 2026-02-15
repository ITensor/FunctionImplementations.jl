using Aqua: Aqua
using FunctionImplementations: FunctionImplementations
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(FunctionImplementations)
end
