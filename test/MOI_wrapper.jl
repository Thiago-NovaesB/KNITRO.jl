using KNITRO, Test
using MathOptInterface
const MOI = MathOptInterface
const MOIT = MOI.Test
const MOIU = MOI.Utilities
const MOIB = MOI.Bridges


MOIU.@model(KnitroModelData,
            (),
            (MOI.EqualTo, MOI.GreaterThan, MOI.LessThan),
            (MOI.Zeros, MOI.Nonnegatives, MOI.Nonpositives),
            (),
            (MOI.SingleVariable,),
            (MOI.ScalarAffineFunction, MOI.ScalarQuadraticFunction),
            (MOI.VectorOfVariables,),
            (MOI.VectorAffineFunction,))

# Without fixed_variable_treatment set, duals are not computed for variables
# that have lower_bound == upper_bound.
const optimizer = KNITRO.Optimizer()
const config = MOIT.TestConfig(atol=1e-4, rtol=1e-4)

#= @testset "MOI Linear tests" begin =#
#=     exclude = ["linear8a", # Behavior in infeasible case doesn't match test. =#
#=                "linear12", # Same as above. =#
#=                "linear8b", # Behavior in unbounded case doesn't match test. =#
#=                "linear8c", # Same as above. =#
#=                "linear7",  # VectorAffineFunction not supported. =#
#=                "linear15", # VectorAffineFunction not supported. =#
#=                ] =#
#=     linear_optimizer = MOI.Bridges.SplitInterval{Float64}(MOIU.CachingOptimizer(KnitroModelData{Float64}(), =#
#=                                                                                 optimizer)) =#
#=     MOIT.linear1test(linear_optimizer, config) =#
#= end =#

#= MOI.empty!(optimizer) =#

@testset "MOI QP/QCQP tests" begin
    qp_optimizer = MOIU.CachingOptimizer(KnitroModelData{Float64}(), optimizer)
    MOIT.qptest(qp_optimizer, config)
    exclude = ["qcp1", # VectorAffineFunction not supported.
              ]
    MOIT.qcptest(qp_optimizer, config, exclude)
end

MOI.empty!(optimizer)

@testset "MOI NLP tests" begin
    MOIT.nlptest(optimizer, config)
end
