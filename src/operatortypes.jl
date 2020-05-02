
abstract type NeutralElement end
abstract type HasNeutralElement <: NeutralElement end
struct HasZero <: HasNeutralElement end
struct HasOne <: HasNeutralElement end
struct HasZeroAndOne <: HasNeutralElement end
struct HasNoNeutralElement <: NeutralElement end

abstract type Idempotency end
struct IsIdempotent <: Idempotency end

NeutralElement(::Type{T}) where T<:Number = HasZeroAndOne()
NeutralElement(::Type{T}) where T<:AbstractString = HasOne()
function NeutralElement(::AbstractArray{T}) where T
    X = NeutralElement(T)
    X isa HasZero || X isa HasZeroAndOne ? HasZero() : HasNoNeutralElement()
end


has_neutral_element(::Function, ::Type) = false
neutral_element(::typeof(+), ::Type{T}) where {T<:Number} = zero() 
neutral_element(::typeof(*), ::Type{T}) where {T<:Number} = one(T) 
neutral_element(::typeof(*), ::Type{T}) where {T<:AbstractString} = "" 
neutral_element(::typeof(max), ::Type{T}) where {T<:AbstractString} = "" 
neutral_element(::typeof(&), ::Type{T}) where {T<:Real} = true 
neutral_element(::typeof(|), ::Type{T}) where {T<:Real} = false 

type_of_image(::typeof(abs), ::Type{T}) where {T<:Number} = T

_return_t(f::Function, ::Type{T}) = Core.Inference.return_type(f, (T,))

function return_typ(f::Function, x::T)
    rt = _return_t(f, T)
    if !isleaftype(rt)
        rt = typeof(f(x))
    end
    rt
end

