
using LinearAlgebra, SparseArrays
export BidiagonalU, BidiagonalL, spcix, spccol, spcrow, spcval

BidiagonalU(a...)= Bidiagonal(a..., :U)
BidiagonalL(a...) = Bidiagonal(a..., :L)

spcix(A) = 1:size(A, 2)
@inline function spcix(A::Matrix, i::Integer)
    m = size(A, 1)
    x = m * (i-1)
    x+1:x+m
end
spcix(A::Vector, i::Integer) = 1:size(A, 1)
spcix(A::Diagonal, i::Integer) = i:i
@inline function spcix(A::Bidiagonal, i::Integer)
    if A.uplo == 'U'
        (i == 1 ? 0 : -1):0
    else
        0:(i == size(A, 2) ? 0 : 1)
    end
end
@inline spcix(A::Tridiagonal, i::Integer) = (i==1 ? 0 : -1):(i == size(A, 2) ? 0 : 1)
spcix(A::SparseMatrixCSC, i::Integer) = A.colptr[i]:A.colptr[i+1]-1
spcix(A::SparseVector, i::Integer) = 1:length(A.nzind)

spccol(A, ix) = ix

@inline spcrow(A::Matrix, ix, j) = (ix - 1) % size(A, 1) + 1
spcrow(A::Vector, ix, j) = ix
spcrow(A::Diagonal, ix, j) = j
spcrow(A::Bidiagonal, ix, j) = j + ix
spcrow(A::Tridiagonal, ix, j) = j + ix
spcrow(A::SparseMatrixCSC, ix, j) = A.rowval[ix]
spcrow(A::SparseVector, ix, j) = A.nzind[ix]

spcval(A::Matrix, ix, j) = A[ix]
spcval(A::Vector, ix, j) = A[ix]
spcval(A::Diagonal, ix, j) = A.diag[ix]
@inline spcval(A::Bidiagonal, ix, j) = ix == 0 ?  A.dv[j] : A.ev[j+(ix-1)>>1]
@inline spcval(A::Tridiagonal, ix, j) = ix == 0 ?  A.d[j] : ix < 0 ? A.du[j+ix] : A.dl[j+(ix-1)>>1]
spcval(A::SparseMatrixCSC, ix, j) = A.nzval[ix]
spcval(A::SparseVector, ix, j) = A.nzval[ix]

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

