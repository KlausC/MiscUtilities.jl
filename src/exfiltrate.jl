
export @exfiltrate, setfield!!

# original version by Stefan Karpinski in slack (2.8.2020)
"""
    setfieled!!(module, var, value)

Set a globla variable in an arbitrary module
"""
setfield!!(m::Module, var::Symbol, val::Any) = m.eval(:($var = $val))


"""
    @exfiltrate

Usage example:
julia> function f(x, y)
           a = 1
           @exfiltrate
           b = "foo"
           return x, b
       end
f (generic function with 1 method)
julia> f(3, 4)
(3, "foo")
julia> x
3
julia> y
4
julia> a
1
julia> b
ERROR: UndefVarError: b not defined
"""
macro exfiltrate()
    quote
        for (var, val) in Base.@locals
            setfield!!(Main, var, val)
        end
    end
end
