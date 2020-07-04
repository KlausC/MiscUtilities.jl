
using LinearAlgebra, SparseArrays
export BidiagonalU, BidiagonalL, spcix, spccol, spcrow, spcval

"""
    spcix(A)

Return an iterator, which delivers all column tags for a matrix.
A column tag can, but need not, be identical to the corresponding column index.

    spcix(A, column-tag)

Return an iterator of element tags for all elements in one column. 

The set of matrix access functions `spcix`, `spccol`, `spcrow` generalize the
way of `SparseMatrixCSC` to access structured matrices in column-major order.
"""
function spcix end

"""
    spccol(A, column-tag)

Return column index corresponding to column tag.

The set of matrix access functions `spcix`, `spccol`, `spcrow` generalize the
way of `SparseMatrixCSC` to access structured matrices in column-major order.
"""
function spccol end
"""
    spcrow(A, element-tag)

Return row index corresponding to row tag.

The set of matrix access functions `spcix`, `spccol`, `spcrow` generalize the
way of `SparseMatrixCSC` to access structured matrices in column-major order.
"""
function spcrow end
"""
    spcval(A, element-tag)

Return value stored in element.
"""
function spcval end

const ColumnTag = Int
const ElementTag = Int
const AbstractMatrixVector{T} = Union{AbstractMatrix{T},AbstractVector{T}}

# convenience constructors for upper- and lower bidiagonal matrices
BidiagonalU(a...)= Bidiagonal(a..., :U)
BidiagonalL(a...) = Bidiagonal(a..., :L)

spcix(A::AbstractMatrixVector) = 1:size(A, 2)
# use linear indices
@inline function spcix(A::DenseMatrix, i::ColumnTag)
    # assume 1-based indices
    m = size(A, 1)
    x = m * (i-1)
    x+1:x+m
end
spcix(A::AbstractVector, i::ColumnTag) = 1:size(A, 1) # ignore column index for vectors
spcix(A::Diagonal, i::ColumnTag) = i:i
@inline function spcix(A::Bidiagonal, i::ColumnTag)
    if A.uplo == 'U'
        (i == 1 ? 0 : -1):0
    else
        0:(i == size(A, 2) ? 0 : 1)
    end
end
@inline spcix(A::Tridiagonal, i::ColumnTag) = (i==1 ? 0 : -1):(i == size(A, 2) ? 0 : 1)
spcix(A::SparseMatrixCSC, i::ColumnTag) = A.colptr[i]:A.colptr[i+1]-1
spcix(A::SparseVector, i::ColumnTag) = 1:length(A.nzind)

spccol(A::AbstractMatrixVector, ix::ColumnTag) = Int(ix)

@inline spcrow(A::DenseMatrix, ix::ElementTag, j::ColumnTag) = (ix - 1) % size(A, 1) + 1
spcrow(A::Vector, ix::ElementTag, j::ColumnTag) = ix
spcrow(A::Diagonal, ix::ElementTag, j::ColumnTag) = j
spcrow(A::Bidiagonal, ix::ElementTag, j::ColumnTag) = j + ix
spcrow(A::Tridiagonal, ix::ElementTag, j::ColumnTag) = j + ix
spcrow(A::SparseMatrixCSC, ix::ElementTag, j::ColumnTag) = A.rowval[ix]
spcrow(A::SparseVector, ix::ElementTag, j::ColumnTag) = A.nzind[ix]

spcval(A::DenseMatrix, ix::ElementTag, j::ColumnTag) = A[ix]
spcval(A::Vector, ix::ElementTag, j::ColumnTag) = A[ix]
spcval(A::Diagonal, ix::ElementTag, j::ColumnTag) = A.diag[ix]
@inline spcval(A::Bidiagonal, ix::ElementTag, j::ColumnTag) = ix == 0 ?  A.dv[j] : A.ev[j+(ix-1)>>1]
@inline spcval(A::Tridiagonal, ix::ElementTag, j::ColumnTag) = ix == 0 ?  A.d[j] : ix < 0 ? A.du[j+ix] : A.dl[j+(ix-1)>>1]
spcval(A::SparseMatrixCSC, ix::ElementTag, j::ColumnTag) = A.nzval[ix]
spcval(A::SparseVector, ix::ElementTag, j::ColumnTag) = A.nzval[ix]


# This test function illustrates, how the `spcix`, `spccol`, `spcrow` collaborate
# to access all elements of a matrix in column-major order.
function spctest(A)
    B = zeros(eltype(A), size(A)...)
    for jx in spcix(A)
        j = spccol(A, jx)
        for ix in spcix(A, jx)
            i = spcrow(A, ix, jx)
            B[i,j] = spcval(A, ix, jx)
        end
    end
    A == B
end

# output generation

abstract type SpcCollector end

struct ArrayCollector{Tv,S} <: SpcCollector
    dest::S
end

mutable struct SparseCollector{Tv,S} <: SpcCollector
    dest::S
    xb::BitVector
    ip::Int
    k0::Int
    function SparseCollector(A::S, ma::Integer) where {Tv,Ti,S<:AbstractSparseArray{Tv,Ti}}
        ma = max(ma, size(A, 1))
        new{Tv,S}(A, fill(false, ma), 0, 0)
    end
end

function spcbuffer(C, A)
    ArrayCollector{eltype(C), typeof(C)}(C)
end

function spcbuffer(A::AbstractSparseArray{Tv,Ti}, ma::Integer) where {Tv,Ti}
    SparseCollector(A, ma)
end
 
function spcadd!(c::ArrayCollector, row::Integer, col::Integer, val)
    c.dest[row,col] += val
end
function spcadd!(c::SparseCollector, row::Integer, col::Integer, val)
    k = row
    if c.xb[k]
        c.S.nzva[c.k0+k] += val
    else
        c.S.nzva[c.k0+k] = val
        c.xb[k] = true
        c.S.rowval[c.ip] = k
        c.ip += 1
    end 
end

function spcnext!(c::ArrayCollector, col::Integer)
    nothing
end
function spcnext!(c::SparseCollector, col::Integer)
    # copy from spmatmul - prepare collector for next column
    nothing
end

function spcend!(c::ArrayCollector)
    nothing
end
function spcend!(c::SparseCollector)
    # copy from spmatmul - finish up collector
    nothing
end



