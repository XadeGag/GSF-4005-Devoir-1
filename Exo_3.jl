#------------------------------------SM : Ch.2, p.95, problème 9 [en Julia]#------------------------------------#
using Random, StatsBase, Plots

# After some researches, we know that:
# If X₁,…,X_N ~ i.i.d. Uniform(0,1), then:
    # Y = min(X₁,…,X_N) ~ Beta(1, N)
# The Prob density function for this is:
    # f_Y(t) = N*(1 - t)^(N-1),      0 ≤ t ≤ 1
# And the cumulative distr function is:
    # F_Y(t) = 1 - (1 - t)^N,        0 ≤ t ≤ 1
# Also, E[Y] = 1/(N+1),  Var[Y] = N/((N+1)^2*(N+2))


function simulate_mins(N::Int, trials::Int)
    # Each row is one trial of N uniforms; take the row-minimum
    R = rand(trials, N)
    return map(minimum, eachrow(R)) |> collect
end

trials = 200_000
N = 10
mins = simulate_mins(N, trials)

println("For N = $N:  empirical mean(min) = $(mean(mins))  | theory = $(1/(N+1))")

ts = range(0, 1; length=400)

# Histogram + theoretical PDF
plt_pdf = histogram(mins; bins=60, normalize=:pdf, alpha=0.4, label="Empirical (N=$N)",
                    xlabel="t", ylabel="density", title="min of N Uniform(0,1)")
plot!(plt_pdf, ts, N .* (1 .- ts).^(N-1); lw=2, label="Theoretical PDF")
display(plt_pdf)

# Empirical CDF + theoretical CDF
ec = ecdf(mins)
plt_cdf = plot(ts, ec.(ts); lw=2, label="Empirical CDF",
               xlabel="t", ylabel="CDF", title="CDF of min (N=$N)")
plot!(plt_cdf, ts, 1 .- (1 .- ts).^N; lw=2, ls=:dash, label="Theoretical CDF")
display(plt_cdf)

# ----- How results depend on N: repeat for multiple N -----
for N in (2, 5, 10, 50, 100)
    minsN = simulate_mins(N, trials)
    println("N=$N  mean(min) ≈ $(round(mean(minsN), digits=5))  (theory: $(round(1/(N+1), digits=5)))")

    plt = histogram(minsN; bins=60, normalize=:pdf, alpha=0.35,
                    xlabel="t", ylabel="density",
                    title="Distribution of min for N = $N", label="Empirical")
    plot!(plt, ts, N .* (1 .- ts).^(N-1); lw=2, label="Theoretical PDF")
    display(plt)
end

# Conclusion:
# Simulations confirm that Y = min(X₁,…,X_N) (X_i ~ U(0,1)) follows Beta(1,N).
# Empirical hist/CDF match theory: f(t)=N(1-t)^(N-1), F(t)=1-(1-t)^N.
# As N increases, Y concentrates near 0; E[Y]=1/(N+1) decreases accordingly.
# Monte Carlo estimates of P(Y ≤ t) align with the theoretical CDF within sampling error.
