using Random

export randsubset

"""
    randsubset([rng=GLOBAL_RNG,] A, m::Integer)

Return random subset of `A` with `m` elements.
If `A` is an `AbstractSet` return a set of the same type.
Otherwise return a `Vector` with the element type of `A`.
If `A` is not unique, result is not unique.
"""
randsubset(A, m::Integer) = randsubset(Random.GLOBAL_RNG, A, m)
function randsubset(rng::AbstractRNG, A, m::Integer)
    randsubset(rng, collect(A), m)
end
function randsubset(rng::AbstractRNG, A::AbstractSet, m::Integer)
    typeof(A)(randsubset(rng, collect(A), m))
end
function randsubset(rng::AbstractRNG, A::AbstractVector, m::Integer)
    A[randsubset(rng, axes(A, 1), m)]
end
function randsubset(rng::AbstractRNG, A::AbstractUnitRange, m::Integer)
    n = length(A)
    0 <= m <= n || throw(ArgumentError("required 0 <= m <= $n but m = $m"))
    m == 0 && return eltype(A)[]
    m == n && return collect(A)
    if m<<1 > n
        deleteat!(collect(A), _randsubset(rng, 1:n, n-m))
    else
        _randsubset(rng, A, m)
    end
end

function _randsubset(rng::AbstractRNG, A::AbstractUnitRange, m::Integer)
    x = randsubseq(rng, A, m / length(A))
    k = length(x)
    while k < m
        x = unique!(sort!(vcat(x, randsubset(rng, A, m - k))))
        k = length(x)
    end
    while k > m
        y = unique!(sort!(rand(rng, 1:k, k-m)))
        deleteat!(x, y)
        k = length(x)
    end
    x
end

