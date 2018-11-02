
# SAT solvers

## problem definition in a nutshell

_SAT_ is a NP-complete problem also called "[satisfiability problem](http://en.wikipedia.org/wiki/Boolean_satisfiability_problem)".
It is most often presented in the form of a set of boolean
clauses, each of those being a disjunction of literals. A literal
is either a proposition or its negation. The problem goal is to
find whether it exists a valuation for those boolean literals such
that all clauses are true, and, in this case, to give such a
valuation. In other words, can we give each proposition a truth value such that all clauses have at least one true literal?

A simple example is:

    a or (not b)
    b or c
    (not a) or (not c)
    (not c)

which is satisfiable by the valuation `a=1, b=1, c=0`

## Dimacs syntax

There exists a simple, straighfoward standard format used
to facilitate reading of a problem by a solver.

It is composed of:

* comments (lines beginning with `'c'`)
* a line defining the problem, with format `p <n> <n>`. The
two numbers define the number of variables (propositions)
and the number of clauses, respectively.
* a sequence of positive or negative numbers (not 0)
that represent the clauses themselves. A negative number
`-9` represents the literal `(not x9)` where `x9` is the
ninth proposition. A positive number just represents a
proposition. Each clause (a list of literals) is ended by a
0, which cannot be a proposition since there would be no way
to tell `x0` from `(not x0)`.

Another example:

    c a very personal comment on this problem
    c talking about clauses and literals
    p 3 2
    1 2 3 0
    2 -3 0

It represents the logical problem

    x1 or x2 or x3
    x2 or (not x3)

## problems

A [list](assets/cnf "cnf problems") of a few problem (quite)
simple on which to test a SAT-solver, in Dimacs format.

## solver

I have been working on a (relatively) efficient SAT-solver written
in Java. It implements the [DPLL](http://en.wikipedia.org/wiki/DPLL_algorithm "DPLL") algorithm, with the following features:


* _two-watched literals_ for fast boolean propagation
* _backjumping_ and _clause learning_ with _1-UIP_
* _restarts_
* research guided by literals activity (_VSIDS_)

Some lacking features are:

* better heuristics (notably for restarts)
* clause forgetting (garbage collecting learnt clauses)

