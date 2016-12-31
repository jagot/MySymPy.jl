using SymPy

function walk_expression(fun::Function, ex::Sym)
    as = map(args(ex)) do a
        walk_expression(fun, a)
    end
    if length(as) == 0 # Due to issue SymPy.jl#103
        ex
    else
        fun(func(ex)(as...))
    end
end

# Is there a nicer way?
is_exp(ex) = (func(ex) == func(exp(sympy[:Dummy]("x"))))

function trans_gaussian(ex, x)
    is_exp(ex) || return ex
    arg = args(ex)[1]
    A,B,C = symbols("__A __B __C")
    s = solve(A*(x+B)^2 + C - arg, [A,B,C])[1]
    ks = keys(s)
    all([S in ks for S in [A,B,C]]) || return ex
    # Would actually like to test for negative
    # definiteness here, but how?
    # s[A] < 0 || return ex
    p = simplify(s[A]*(x+s[B])^2 + s[C])
    exp(p)
end

export walk_expression, trans_gaussian
