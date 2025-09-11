
# ================================================================
# Equally likely vs. conditional equally likely (simplified)
# ------------------------------------------------
# Goal: Compare interpoint distances from
#   (A) n sorted Uniform(0,1) samples, and
#   (B) a Poisson(λ) process on [0,1] *conditioned* on having exactly n events.
#
# Fact: (B) given N(1)=n has the same law as (A).
#       The n+1 spacings (including the ends) are Dirichlet(1,...,1).
#       The n-1 *interpoint distances* are the middle spacings.
# ================================================================

using Random, Distributions, Plots

# ---------- 1) Interpoint distances from n uniforms ----------
# Return the n-1 differences between consecutive order statistics
function uniform_interspacings(n::Integer)
    x = sort(rand(n))     # n Uniform(0,1), sorted
    return diff(x)        # interpoint distances (length n-1)
end

# ---------- 2) Conditional Poisson interspacings (no rejection) ----------
# Sample n+1 i.i.d. Exp(1), normalize to sum to 1 (Dirichlet(1,…,1)).
# The *internal* interpoint distances are exactly the middle n-1 spacings.
function conditional_poisson_interspacings(n::Integer)
    y = rand(Exponential(1.0), n + 1)  # n+1 Exp(1). Thoses are the spacings of a Poisson(1) process on [0,∞)

    y ./= sum(y)                        # Dirichlet(1,…,1) spacings on [0,1]. After doing this, the number of spacings doesn't matter  
                                        # because they are Dirichlet....

    return y[2:n]                       # internal spacings only
end

# ---------- 3) Naive rejection sampler ----------
# Simulate Exp(λ) inter-arrivals; accept only if exactly n events fall in [0,1].
# NOTE: Exponential in Distributions.jl uses *scale* (mean), so pass 1/λ.
function poisson_interspacings_rejection(n::Integer; λ::Real = n)
    λ = float(λ)
    t = 0.0
    times = Float64[]
    while t < 1
        t += rand(Exponential(1/λ))
        t < 1 && push!(times, t)
    end
    if length(times) == n
        sort!(times)
        return diff(times)     # interpoint distances (length n-1)
    else
        return nothing         # rejected run
    end
end

# ---------- 4) Small driver ----------
function main(; n::Int = 50, reps::Int = 10_000, seed::Int = 1)
    Random.seed!(seed)

    # Collect many interpoint distances from each method
    inter_u = Float64[]
    inter_c = Float64[]

    for _ in 1:reps
        append!(inter_u, uniform_interspacings(n))
        append!(inter_c, conditional_poisson_interspacings(n))
    end

    # Plot both histograms together (they should overlap)
    nbins = 60
    plt = histogram(inter_u; bins=nbins, normalize=:pdf, alpha=0.45,
                    label="Uniform order stats",
                    xlabel="interpoint distance", ylabel="density",
                    title="Interpoint distances (n = $n)")
    histogram!(plt, inter_c; bins=nbins, normalize=:pdf, alpha=0.45,
               label="Conditional Poisson (Dirichlet)")
    display(plt)

    # How inefficient is the rejection idea when λ = n?
    p_accept = pdf(Poisson(n), n)             # exact P(N(1)=n)
    approx   = 1 / sqrt(2π * n)               # ≈ 1/√(2πn)
    println("P(accept at n=$n, λ=$n) = $p_accept  (≈ $approx)")
    println("Expected rejections per acceptance ≈ $(round(1/p_accept - 1, digits=2))")

    # Tiny empirical check (keep small so it runs fast)
    accepted = 0; tried = 0
    while accepted < 50               # gather 50 accepted paths
        s = poisson_interspacings_rejection(n; λ=n)
        tried += 1
        accepted += s === nothing ? 0 : 1
    end
    println("Empirical acceptance rate ≈ $(round(accepted/tried, digits=4))  (from $tried trials)")
end

# Run
main()


# Conclusion:
# The interpoint distances from (A) n sorted Uniform(0,1) samples
# and (B) a Poisson(λ) process on [0,1] conditioned on having exactly n events
# have the same distribution (Dirichlet(1,…,1) spacings).
# The histograms from both methods overlap closely.
# The rejection method for (B) is very inefficient for large n,
# with acceptance probability ≈ 1/√(2πn).