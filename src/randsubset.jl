using Random

export randsubset

"""
    randsubset([rng=GLOBAL_RNG,]A::AbstractArray, m::Integer)

Return

"""
randsubset(A::AbstractArray, m::Integer) = randsubset(Random.GLOBAL_RNG, A, m)
function randsubset(rng::AbstractRNG, A::AbstractArray, m::Integer)
    n = length(A)
    0 <= m <= n || throw(ArgumentError("required 0 <= m <= $n but m = $m"))
    m == 0 && return eltype(A)[]
    m == n && return A
    if m<<1 > n
        deleteat!(collect(A), _randsubset(rng, 1:n, n-m))
    else
        _randsubset(rng, A, m)
    end
end

function _randsubset(rng::AbstractRNG, A::AbstractArray, m::Integer)
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

