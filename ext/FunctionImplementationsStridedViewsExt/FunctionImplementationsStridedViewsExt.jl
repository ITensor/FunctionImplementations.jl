module FunctionImplementationsStridedViewsExt

using FunctionImplementations: FunctionImplementations
using StridedViews: StridedView

# `permutedims` is lazy for `StridedView` so we can just call it directly.
function FunctionImplementations.permuteddims(a::StridedView, perm)
    return permutedims(a, perm)
end

end
