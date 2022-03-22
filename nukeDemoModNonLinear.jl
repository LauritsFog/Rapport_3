using GLPK, Cbc, JuMP, SparseArrays
using CSV, DataFrames

H = vec(Matrix{Float64}(DataFrame(CSV.File("interHeight.csv"))))

# H = [10 30 70 50 70 120 140 120 100 80]

K = [300 140 40]

function constructA(H,K)
    A = zeros(length(H), length(H))
    for i = 1:size(H)[1]
        for j = 1:size(H)[1]
            if i == j
                A[i,j] = K[1]
            elseif i == j+1 || i == j-1
                A[i,j] = K[2]
            elseif i == j+2 || i == j-2
                A[i,j] = K[3]
            end
        end
    end
    return A
end

function solveIP(H, K)
    h = length(H)
    myModel = Model(Cbc.Optimizer)
    # If your want ot use GLPK instead use:
    #myModel = Model(GLPK.Optimizer)

    A = constructA(H,K)

    @variable(myModel, x[1:h], Bin )
    @variable(myModel, R[1:h] >= 0 )
    @variable(myModel, u[1:h] >= 0)

    @objective(myModel, Min, sum(u[j] for j=1:h) )

    @constraint(myModel, [j=1:h],R[j] >= H[j] + 10 )
    @constraint(myModel, [i=1:h],R[i] == sum(A[i,j]*x[j] for j=1:h) )
    @constraint(myModel, [i=1:h],-(R[i]-H[i]-10) <= u[i])
    @constraint(myModel, [i=1:h],u[i]<=R[i]-H[i]-10)
    # Constraint for preventing bombs next to each other:
    # @constraint(myModel, [i=1:h-1],x[i]+x[i+1] <= 1)

    optimize!(myModel)

    if termination_status(myModel) == MOI.OPTIMAL
        println("Objective value: ", JuMP.objective_value(myModel))
        println("x = ", JuMP.value.(x))
        println("R = ", JuMP.value.(R))
        CSV.write("xValuesNonLinear.csv",  Tables.table(JuMP.value.(x)), header=false)
        CSV.write("RValuesNonLinear.csv",  Tables.table(JuMP.value.(R)), header=false)
    else
        println("Optimize was not succesful. Return code: ", termination_status(myModel))
    end
end

solveIP(H,K)
