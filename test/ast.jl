
cases = [
# Calls
:(f(x)) "(call f x)"
:(f(x, y=1, z=2)) "(call f x (kw y 1) (kw z 2))"
:(f(x; y=1)) "(call f (parameters (kw y 1)) x)"
:(f(x...)) "(call f (... x))"
:(f(x) do a,b
    body
end) "(do (call f x) (-> (tuple a b) (block body)))"
# Operators
:(x+y) "(call + x y)"
:(a+b+c+d) "(call + a b c d)"
:(2x) "(call * 2 x)"
:(a&&b) "(&& a b)"
:(x += 1) "(+= x 1)"
:(a ? 1 : 2) "(if a 1 2)"
:(a:b) "(call : a b)" #
:(a:b:c) "(call : a b c)" #
:(a,b) "(tuple a b)"
:(a==b) "(call == a b)"
:(1<i<=n) "(comparison 1 < i <= n)"
:(a.b) "(. a (quote b))"
:(a.(b)) "(. a (tuple b))"
# Bracketed forms
:(a[i]) "(ref a i)"
:(t[i;j]) "(typed_vcat t i j)"
:(t[i j]) "(typed_hcat t i j)"
:(t[a b; c d]) "(typed_vcat t (row a b) (row c d))"
:(a{b}) "(curly a b)"
:(a{b;c}) "(curly a (parameters c) b)"
:([x]) "(vect x)"
:([x,y]) "(vect x y)"
:([x;y]) "(vcat x y)"
:([x y]) "(hcat x y)"
:([x y; z t]) "(vcat (row x y) (row z t))"
:([x for y in z, a in b]) "(comprehension (generator x (= y z) (= a b)))" #
:(T[x for y in z]) "(typed_comprehension T (generator x (= y z)))" #
:((a, b, c)) "(tuple a b c)"
:((a; b; c)) "(block a b c)" #
# Macros
:(@m x y) "(macrocall @m x y)"
:(Base.@m x y) "(macrocall (. Base (quote @m)) x y)"
:(@Base.m x y) "(macrocall (. Base (quote @m)) x y)"
# Strings
:("a") "\"a\""
:(x"y") "(macrocall @x_str \"y\")"
:(x"y"z) "(macrocall @x_str \"y\" \"z\")"
:("x = $x") "(string \"x = \" x)"
:(`a b c`) "(macrocall (|.| Core @cmd) \"a b c\")"
(quote
"some docs"
f(x) = x
end).args[2] "(macrocall (|.| Core @doc) \"some docs\" (= (call f x) (block x)))"
# Imports and such
:(import a) "(import (. a))"
:(import a.b.c) "(import (. a b c))"
:(import ...a) "(import (. . . . a))"
:(import a.b, c.d) "(import (. a b) (. c d))"
:(import Base: x) "(import (: (. Base) (. x)))"
:(import Base: x, y) "(import (: (. Base) (. x) (. y)))"
:(export a, b) "(export a b)"
# Numbers
:(11111111111111111111) "(macrocall (|.| Core @int128_str) nothing \"11111111111111111111\")"
:(0xfffffffffffffffff) "(macrocall (|.| Core @uint128_str) nothing \"0xfffffffffffffffff\")"
:(1111111111111111111111111111111111111111) "(macrocall (|.| Core @big_str) nothing \"1111111111111111111111111111111111111111\")"
# Blocks
(quote
if a
    b
elseif c
    d
else
    e
end
end).args[2] "(if a (block b) (elseif (block c) (block d) (block e)))"
:(while condition; body; end) "(while condition (block body))" #
:(for var = iter; body; end) "(for (= var iter) (block body))" #
:(for v1=iter1, v2=iter2; body; end) "(for (block (= v1 iter1) (= v2 iter2)) (block body))" #
:(break) "(break)"
:(continue) "(continue)"
:(let var=iter; body; end) "(let (= var iter) (block body))"
:(let v1=iter1, v2=iter2; body; end) "(let (block (= v1 iter1) (= v2 iter2)) (block body))"
:(f(x) = body) "(= (call f x) (block body))" #
:(function f(x::T; k = 1) where T
    return x+1
end) "(function (where (call f (parameters (kw k 1)) (:: x T)) T) (block (return (call + x 1))))"
:(mutable struct Foo{T<:S}
    x::T
end) "(struct true (curly Foo (<: T S)) (block (:: x T)))"
:(try; try_block;catch var; catch_block; finally finally_block; end) "(try (block try_block) var (block catch_block) (block finally_block))"
:(try; try_block;catch; catch_block; finally finally_block; end) "(try (block try_block) false (block catch_block) (block finally_block))"
:(try; try_block;catch var; catch_block; end) "(try (block try_block) var (block catch_block))"
:(try; try_block;catch; catch_block; end) "(try (block try_block) false (block catch_block))" #
]

@testset "AST example $i" for i = 1:size(cases, 1) 
    @test pexpressions(cases[i,1]) == cases[i,2]
end


