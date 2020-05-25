
using LinearAlgebra, SparseArrays
export BidiagonalU, BidiagonalL, spcix, spcrow, spcval

BidiagonalU(a...)= Bidiagonal(a..., :U)
BidiagonalL(a...) = Bidiagonal(a..., :L)

function spcix(A::Matrix, i::Integer)
    m = size(A, 1)
    x = m * (i-1)
    x+1:x+m
end
spcix(A::Vector, i::Integer) = 1:size(A, 1)
spcix(A::Diagonal, i::Integer) = i:i
function spcix(A::Bidiagonal, i::Integer)
    if A.uplo == 'U'
        (i==1 ? 0 : -1):0
    else
        0:(i == size(A, 2) ? 0 : 1)
    end
end
spcix(A::Tridiagonal, i::Integer) = (i==1 ? 0 : -1):(i == size(A, 2) ? 0 : 1)
spcix(A::SparseMatrixCSC, i::Integer) = A.colptr[i]:A.colptr[i+1]-1
spcix(A::SparseVector, i::Integer) = 1:length(A.nzind)

spcrow(A::Matrix, ix, j) = (ix - 1) % size(A, 1) + 1
spcrow(A::Vector, ix, j) = ix
spcrow(A::Diagonal, ix, j) = j
spcrow(A::Bidiagonal, ix, j) = j + ix
spcrow(A::Tridiagonal, ix, j) = j + ix
spcrow(A::SparseMatrixCSC, ix, j) = A.rowval[ix]
spcrow(A::SparseVector, ix, j) = A.nzind[ix]

spcval(A::Matrix, ix, j) = A[ix]
spcval(A::Vector, ix, j) = A[ix]
spcval(A::Diagonal, ix, j) = A.diag[ix]
spcval(A::Bidiagonal, ix, j) = ix == 0 ?  A.dv[j] : A.ev[j+(ix-1)>>1]
spcval(A::Tridiagonal, ix, j) = ix == 0 ?  A.d[j] : ix < 0 ? A.du[j+ix] : A.dl[j+(ix-1)>>1]
spcval(A::SparseMatrixCSC, ix, j) = A.nzval[ix]
spcval(A::SparseVector, ix, j) = A.nzval[ix]

function spctest(A)
    B = zeros(eltype(A), size(A)...)
    for j in axes(A, 2)
        for ix in spcix(A, j)
            i = spcrow(A, ix, j)
            B[i,j] = spcval(A, ix, j)
        end
    end
    A == B
end

