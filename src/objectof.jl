module Objectof

export objectof, hasobjectof

objectof(::Type{Any}) = nothing
objectof(::Type{Nothing}) = nothing
objectof(::Type{Missing}) = missing
objectof(::Type{T}) where T<:Number = zero(T)
objectof(::Type{T}) where T<:AbstractString = (T == AbstractString ? String : T)("")
objectof(::Type{Union{}}) = Union{}()
objectof(::Type{<:Ref{T}}) where T = Ref{T}(objectof(T))
objectof(::Type{T}) where T<:AbstractRange = convert(T, 1:0)
objectof(::Type{T}) where T<:Function = T === Function ? identity : T.instance

function objectof(::Type{Array{T,N}}) where {T,N}
    N isa Integer && N >= 0 || throw(ArgumentError("array dimensions must be integers >= 0"))
    A = Array{T,N}(undef, zeros(Int, N)...)
    if N == 0
        A[] = objectof(T)
    end
    A
end

function objectof(::Type{T}) where T
    if typeof(T) == Union
        hasobjectof(T.a) ? objectof(T.a) : objectof(T.b)
    elseif typeof(T) == DataType
        T(objectof.(T.types)...)
    elseif typeof(T) == UnionAll
        objectof(T{T.var.ub})
    else
        throw(ArgumentError("cannot create object of type $T"))
    end
end

hasobjectof(::Type{Any}) = true
hasobjectof(::Type{Nothing}) = true 
hasobjectof(::Type{Missing}) = true
hasobjectof(::Type{T}) where T<:Number = true
hasobjectof(::Type{T}) where T<:AbstractString = true
hasobjectof(::Type{Union{}}) = false
hasobjectof(::Type{<:Ref{T}}) where T = hasobjectof(T)
hasobjectof(::Type{T}) where T<:AbstractRange = T in (AbstractRange, OrdinalRange, AbstractStepRange) || typeof(T) != UnionAll
hasobjectof(::Type{T}) where T<:Function = true

hasobjectof(::Type{Array{T,N}}) where {T,N} = true

function hasobjectof(::Type{T}) where T
    if typeof(T) == Union
        hasobjectof(T.a) || hasobjectof(T.b)
    elseif typeof(T) == DataType
        all(hasobjectof.(T.types)) && hasmethod(T, tuple(T.types...)) 
    elseif typeof(T) == UnionAll
        hasobjectof(T{T.var.ub})
    else
        false
    end
end

end # module
