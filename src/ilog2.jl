
export ilog2

"""
    ilog2(a::Integer)::Int

For nonzero integers `a` return Int(floor(log2(abs(a))))
For zero return `-1`
"""
function ilog2(a::Integer)
    ndigits(a, base=2, pad=0) - 1
end
#=
function ilog2(a::BigInt)
    Limb = Base.GMP.Limb
    sol = sizeof(Limb)
    bpl = sol * 8
    siz = max(abs(a.size), 1)
    v = unsafe_wrap(Vector{Limb}, a.d + (siz - 1) * sol, 1)
    msl = v[1]
    siz * bpl - 1 - leading_zeros(msl)
end
=#
function ilog2(a::Base.BitInteger)
    bpl = sizeof(a) * 8
    bpl - 1 - leading_zeros(abs(a))
end

