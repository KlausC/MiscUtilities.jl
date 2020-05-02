
using Base

# referred base types or modules
import Base:    Indices, CommonReduceResult, SmallSigned, SmallUnsigned,
                OneTo, Bottom, Generator, BitInteger_types, Broadcast,
                ReshapedArray, SparseArrays
                
# related to traits                
import Base:    HasLength, HasShape, SizeUnknown, HasEltype, EltypeUnknown,
                IteratorSize

# they are used only
import Base:    scalarmin, scalarmax, uniontypes, arraylen, sizeof, safe_tail, tail,
                indices1, getindex, setindex!, setindex_shape_check, one, zero

# those are re-defined and overwritten
import Base:    sum, sum!, prod, prod!, minimum, minimum!, maximum, maximum!,
                all, all!, any, any!,
                convert, copy, copy!, size, length, _length,
                reducedim, mapreduce_impl,
                findmin, findmin!, findmax, findmax!

import Base.==
                

# macros
import Base:    @_inline_meta, @_noinline_meta, @_propagate_inbounds_meta

