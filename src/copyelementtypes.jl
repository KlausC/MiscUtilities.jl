
export copy_elementtype

    copy_elementtype(T, x::R) where R<:AbstractArray = T.(x)
    copy_elementtype(T, x::UpperTriangular) = UpperTriangular(copy_elementtype(T, parent(x)))
    copy_elementtype(T, x::LowerTriangular) = LowerTriangular(copy_elementtype(T, parent(x)))
    copy_elementtype(T, x::R) where R<:Transpose = Transpose(copy_elementtype(T, parent(x)))
    copy_elementtype(T, x::R) where R<:Adjoint = Adjoint(copy_elementtype(T, parent(x)))
    copy_elementtype(T, x::R) where R<:Symmetric = Symmetric(copy_elementtype(T, parent(x)), Symbol(x.uplo))
    copy_elementtype(T, x::R) where R<:Hermitian = Hermitian(copy_elementtype(T, parent(x)), Symbol(x.uplo))

if isdefined(@__MODULE__, :BandedMatrices)
    copy_elementtype(T, a::BandedMatrix) = BandedMatrix((d -> d => T.(diag(a, d))).(-a.l:a.u)...)
end
