
using Base.Threads

export spawnloop

function spawnloop(f, n)
    fence[] = 0
    @threads for i = 1:n
        f(Val(i))
    end
end

const fence = Atomic{Int}(0)

function fun(::Val{N}) where N
    b = a = 0
    n = 0
    t = 0
    while a == b
        # t0 = time_ns()
        a = fence[]
        # t1 = time_ns()
        #t += Int(t1 - t0)
        n += 1
    end
    println(N, "(", threadid(), ") :", n, " ", t)
end

function fun(::Val{1})
    sleep(0.001)
    t0 = time_ns()
    fence[] = 1
    t1 = time_ns()
    println(1, "(", threadid(), ") time = ", Int(t1-t0))
end


function releaseto(a::Atomic{T}, v::T) where T
    a[] = v
    v
end
function releaseto(::Any, v::T) where T
    v
end

function waitfor(my::Atomic{T}, v::T) where T
    av = my[]
    while v > av
        av = my[]
    end
    av
end

function waitfor(delta::T, v::T) where T
    v + delta
end

function stepforward(my::Union{T,Atomic}, next::Union{T,Atomic}, irel::T, ineed::T) where T
    releaseto(next, irel)
    waitfor(my, ineed)
end

N = 10^6

function funsweep(n::Integer)
    A = [Atomic{Int}(0) for i = 1:n]
    @threads for t = 1:n
        println("starting thread $t")
        my = t == 1 ? 1000 : A[t]
        nx = t == n ? 0 : A[t+1]
        i = 1
        v = 1
        while i < N
            # println("a i = $i, tid = $t, v = $v")
            v = stepforward(my, nx, i, v)
            # println("b i = $i, tid = $t, v = $v")
            while i <= min(v, N)
                dojob(i, t)
                i += 1
            end
        end
        stepforward(0, nx, i, 0)
    end
end

const B = zeros(Int, N)
function dojob(i, t)
    B[i] |= 1<<(t-1)
    # println("i = $i , tid = $t")
end

