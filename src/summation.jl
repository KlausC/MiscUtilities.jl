
export compensated_sum, recursive_sum, blocked_sum, fab_sum

# Kahan sum
function compensated_sum(A)
    T = eltype(A)
    sum = c = zero(T)
    for a in A
        y = a - c
        t = sum + y
        c = (t - sum) - y
        sum = t
    end
    return sum
end

function recursive_sum(A)
    T = eltype(A)
    sum = zero(T)
    for a in A
        sum += a
    end
    sum
end

function blocked_sum(A, b::Integer=128)
    n = length(A)
    m = (n+b-1) ÷ b
    S = [recursive_sum(view(A,i*b+1:min(i*b+b,n))) for i = 0:m-1]
    return sum(S)
end

function fab_sum(A, b::Integer=128)
    n = length(A)
    m = (n+b-1) ÷ b
    S = [recursive_sum(view(A,i*b+1:min(i*b+b,n))) for i = 0:m-1]
    return compensated_sum(S)
end
