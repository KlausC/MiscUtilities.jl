
# print AST in Lisp form

export pexpression, pexpressions
"""
    pexpression(quoted expression)

Print readable form in Lisp format `(header arg1 arg2 ...)`.
"""
function pexpression(io::IO, ex::Expr)
    print(io, "(", ex.head)
    for arg in ex.args
        p0 = position(io)
        print(io, " ")
        pexpression(io, arg)
        if position(io) <= p0 + 1
            seek(io, p0)
        end
    end
    print(io, ")")
end

pexpression(io::IO, s::AbstractString) = print(io, '"', s, '"')

function pexpression(io::IO, s::GlobalRef)
    print(io,"(|.| ", string(s.mod), " ", s.name, ")")
end

function pexpression(io::IO, s::QuoteNode)
    print(io, "(quote "); pexpression(io, s.value); print(io, ")")
end

pexpression(io::IO, s) = print(io, s)

pexpression(io::IO, ::LineNumberNode) = nothing

pexpression(s) = pexpression(stdout, s)

pexpressions(s) = sprint(pexpression, s)


