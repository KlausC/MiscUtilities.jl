# This file is a part of Julia. License is MIT: https://julialang.org/license

@testset "indmax, indmin, findmax, findmin" begin
    S = sprand(100,80, 0.5)
    A = Array(S)
    @test indmax(S) == indmax(A)
    @test indmin(S) == indmin(A)
    @test findmin(S) == findmin(A)
    @test findmax(S) == findmax(A)
    for region in [(1,), (2,), (1,2)], m in [findmax, findmin]
        @test m(S, region) == m(A, region)
    end

    S = spzeros(10,8)
    A = Array(S)
    @test indmax(S) == indmax(A) == 1
    @test indmin(S) == indmin(A) == 1

    A = Array{Int}(0,0)
    S = sparse(A)
    iA = try indmax(A) end
    iS = try indmax(S) end
    @test iA === iS === nothing
    iA = try indmin(A) end
    iS = try indmin(S) end
    @test iA === iS === nothing
end

## findmin/findmax/minumum/maximum

stringf(a) = string(full(a))
stringf(a::Tuple) = string("(", stringf(a[1]), ", ", stringf(a[2]), ")")
Base.zero(::Type{T}) where {T<:AbstractString} = ""

A = sparse([1.0 3.0 6.0;
            5.0 2.0 4.0])
for (tup, rval, rind) in [((1,), [1.0 2.0 4.0], [1 4 6]),
                          ((2,), reshape([1.0,2.0], 2, 1), reshape([1,4], 2, 1)),
                          ((1,2), fill(1.0,1,1),fill(1,1,1))]
    println("tup = $tup A = $A")
    @test findmin(A, tup) == (rval, rind)
    @test findmin!(similar(rval), similar(rind), A) == (rval, rind)
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

"""
for (tup, rval, rind) in [((1,), [5.0 3.0 6.0], [2 3 5]),
                          ((2,), reshape([6.0,5.0], 2, 1), reshape([5,2], 2, 1)),
                          ((1,2), fill(6.0,1,1),fill(5,1,1))]
    @test findmax(A, tup) == (rval, rind)
    @test findmax!(similar(rval), similar(rind), A) == (rval, rind)
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

#issue 23209

A = sparse([1.0 3.0 6.0;
            NaN 2.0 4.0])
for (tup, rval, rind) in [((1,), [NaN 2.0 4.0], [2 4 6]),
                          ((2,), reshape([1.0, NaN], 2, 1), reshape([1,2], 2, 1)),
                          ((1,2), fill(NaN,1,1),fill(2,1,1))]
    @test stringf(findmin(A, tup)) == string((rval, rind))
    @test stringf(findmin!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

for (tup, rval, rind) in [((1,), [NaN 3.0 6.0], [2 3 5]),
                          ((2,), reshape([6.0, NaN], 2, 1), reshape([5,2], 2, 1)),
                          ((1,2), fill(NaN,1,1),fill(2,1,1))]
    @test stringf(findmax(A, tup)) == string((rval, rind))
    @test stringf(findmax!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

A = sparse([1.0 NaN 6.0;
            NaN 2.0 4.0])
for (tup, rval, rind) in [((1,), [NaN NaN 4.0], [2 3 6]),
                          ((2,), reshape([NaN, NaN], 2, 1), reshape([3,2], 2, 1)),
                          ((1,2), fill(NaN,1,1),fill(2,1,1))]
    @test stringf(findmin(A, tup))  == string((rval, rind))
    @test stringf(findmin!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

for (tup, rval, rind) in [((1,), [NaN NaN 6.0], [2 3 5]),
                          ((2,), reshape([NaN, NaN], 2, 1), reshape([3,2], 2, 1)),
                          ((1,2), fill(NaN,1,1),fill(2,1,1))]
    @test stringf(findmax(A, tup)) == string((rval, rind))
    @test stringf(findmax!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

A = sparse([Inf -Inf Inf  -Inf;
            Inf  Inf -Inf -Inf])
for (tup, rval, rind) in [((1,), [Inf -Inf -Inf -Inf], [1 3 6 7]),
                          ((2,), reshape([-Inf -Inf], 2, 1), reshape([3,6], 2, 1)),
                          ((1,2), fill(-Inf,1,1),fill(3,1,1))]
    @test stringf(findmin(A, tup))  == string((rval, rind))
    @test stringf(findmin!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

for (tup, rval, rind) in [((1,), [Inf Inf Inf -Inf], [1 4 5 7]),
                          ((2,), reshape([Inf Inf], 2, 1), reshape([1,2], 2, 1)),
                          ((1,2), fill(Inf,1,1),fill(1,1,1))]
    @test stringf(findmax(A, tup)) == string((rval, rind))
    @test stringf(findmax!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

A = sparse([BigInt(10)])
for (tup, rval, rind) in [((2,), [BigInt(10)], [1])]
    @test stringf(findmin(A, tup))  == string((rval, rind))
    @test stringf(findmin!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

for (tup, rval, rind) in [((2,), [BigInt(10)], [1])]
    @test stringf(findmax(A, tup)) == string((rval, rind))
    @test stringf(findmax!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

A = sparse([BigInt(-10)])
for (tup, rval, rind) in [((2,), [BigInt(-10)], [1])]
    @test stringf(findmin(A, tup))  == string((rval, rind))
    @test stringf(findmin!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

for (tup, rval, rind) in [((2,), [BigInt(-10)], [1])]
    @test stringf(findmax(A, tup)) == string((rval, rind))
    @test stringf(findmax!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

A = sparse([BigInt(10) BigInt(-10)])
for (tup, rval, rind) in [((2,), [BigInt(-10)], [2])]
    @test stringf(findmin(A, tup))  == string((rval, rind))
    @test stringf(findmin!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

for (tup, rval, rind) in [((2,), [BigInt(10)], [1])]
    @test stringf(findmax(A, tup)) == string((rval, rind))
    @test stringf(findmax!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

A = sparse(["a", "b"])
for (tup, rval, rind) in [((1,), ["a"], [1])]
    @test stringf(findmin(A, tup))  == string((rval, rind))
    @test stringf(findmin!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(minimum(A, tup)) == string(rval)
    @test stringf(minimum!(similar(rval), A)) == string(rval)
    @test stringf(minimum!(copy(rval), A, init=false)) == string(rval)
end

for (tup, rval, rind) in [((1,), ["b"], [2])]
    @test stringf(findmax(A, tup)) == string((rval, rind))
    @test stringf(findmax!(similar(rval), similar(rind), A)) == string((rval, rind))
    @test stringf(maximum(A, tup)) == string(rval)
    @test stringf(maximum!(similar(rval), A)) == string(rval)
    @test stringf(maximum!(copy(rval), A, init=false)) == string(rval)
end

"""
