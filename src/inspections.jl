
"""
    unsafe_array(a::Array, T::Type, n::Integer)

Return a Vector{T} of n memory locations starting at the address of `a`.
"""
function unsafe_peek(obj::Array, T::Type, n::Integer)
    isimmutable(obj) && throw(ArgumentError("obj is not mutable"))
    unsafe_wrap(Vector{T}, reinterpret(Ptr{T}, pointer_from_objref(obj)), n)
end

function reflect_data(obj::Array)
    p = unsafe_peek(obj, Int, 5)
    data = UInt(p[1])
    length = Int(p[2])
    flags = reinterpret(UInt16, p[3:3])[1]
    elsize = Int32(reinterpret(UInt16, p[3:3])[2])
    offset = reinterpret(UInt32, p[3:3])[2]
    how = UInt8(flags & 0x0003)
    ndims = UInt16((flags>>2) & 0x03ff)
    pooled = Bool((flags>>12) & 0x0001)
    ptrarray = Bool((flags>>13) & 0x0001)
    isshared = Bool((flags>>14) & 0x0001)
    isaligned = Bool((flags>>15) & 0x0001)
    nrows = Int(p[4])
    maxsize = Int(p[5])
    @assert ndims == 1 && obj isa(Vector) || !(obj isa Vector)
    if obj isa Vector
        (data=data, length=length, how=how, ndims=ndims,
        pooled=pooled, ptrarray=ptrarray, isshared=isshared, isaligned=isaligned,
        elsize=elsize, offset=offset, nrows=nrows, maxsize=maxsize)
    elseif ndims == 2
        (data=data, length=length, how=how, ndims=ndims,
        pooled=pooled, ptrarray=ptrarray, isshared=isshared, isaligned=isaligned,
        elsize=elsize, offset=offset, nrows=nrows, ncols=maxsize)
    else
        dims = unsafe_peek(obj, Int, ndims + 3)[4:end]
        (data=data, length=length, how=how, ndims=ndims,
        pooled=pooled, ptrarray=ptrarray, isshared=isshared, isaligned=isaligned,
        elsize=elsize, offset=offset, nrows=dims[1], ncols=dims[2], dims=dims)
    end
end

