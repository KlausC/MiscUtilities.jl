module MethodLists

using InteractiveUtils
using SparseArrays, LinearAlgebra

export collect_ml, basetype, supertypes, functions
export shortname, format

"""
    collect_ml(T::type; fun=nothing, up=T)

Return list of method with type `T` for function `fun`, `T` is restricted by `T <: up`.
Similar to methodswith, restricting types by upper bound.
"""
function collect_ml(T::Type; fun=nothing, up=Any)
    ml = Set{Method}()
    Y = up
    meli(T, ::Nothing) = methodswith(T; supertypes=true)
    meli(T, f) = methodswith(T, f; supertypes=true)
    
    res = Method[]
    for m in meli(T, fun)
        for P in basetype(m.sig).parameters
            if T <: P <: Y
                push!(res, m)
                break
            end
        end
    end
    res
end

function supertypes(T::Type)
    X = supertype(T)
    if X === T
        [T,]
    else
        [T, supertypes(X)...]
    end
end

basetype(u::UnionAll) = basetype(u.body)
basetype(a::Type) = a

function collect_ml(;fun=nothing)
    mlma = collect_ml(AbstractMatrix; fun=fun)
    mlms = collect_ml(SparseMatrixCSC; fun=fun, up=AbstractSparseArray)
    mlva = collect_ml(AbstractVector; fun=fun)
    mlvs = collect_ml(SparseVector; fun=fun,up=AbstractSparseArray)
    mlma, mlms, mlva, mlvs
end

function functions(mla)
    unique!([m.name for m in mla])
end

shortfile(s::Symbol) = shortfile(string(s))
function shortfile(f::String)
    r = findlast("/src/", f)
    if r !== nothing && !isempty(r)
        s = findlast("/", SubString(f, 1:first(r)-1))
        f[first(s)+1:first(r)] * f[last(r):end]
    else
        f
    end
end
function format(m::Method)
    argt = shortname.(basetype(m.sig).parameters[2:end])
    string(m.name, "(", join(argt, ", "), ") -> ", shortfile(m.file), ":", m.line)
end

shortname(d) = string(d)
shortname(::Type{Any}) = "_"
shortname(t::Core.TypeVar) = shortname(t.ub)
function shortname(d::DataType)
    name = string(d.name.name)
    par = shortname.(d.parameters)
    if all(isequal("_"), par)
        par = String[]
    end
    if length(par) > 3
        resize!(par, 4)
        par[4] = ".."
    end
    return isempty(par) ? name : string(name, "{", join(par, ","), "}")
end

shortname(d::UnionAll) = shortname(d.body)
function shortname(u::Union)
    un = unames(u)
    if length(un) > 2
        resize!(un, 3)
        un[3] = "..."
    end
    string("Union{", join(un, ","), "}")
end
unames(d) = shortname(d)
unames(u::Union) = unique(vcat(unames(u.a), unames(u.b)))


end # module
