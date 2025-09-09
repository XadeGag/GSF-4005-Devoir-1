using Random, Distributions, Plots

# ---------- 1) Zombie gap sampler ----------
# Return one "arrival time" (number of uniforms until first U < w)
function zombie_gap(w::Float64)
    count = 0
    while true
        count += 1
        if rand() < w
            return count
        end
    end
end

# ---------- 2) Collect many samples ----------
function simulate_zombie(w::Float64, reps::Int)
    [zombie_gap(w) for _ in 1:reps]
end

# ---------- 3) Compare with exponential ----------
function main(; w=0.2, reps=50_000, seed=1)
    Random.seed!(seed)

    # Simulate zombie gaps
    samples = simulate_zombie(w, reps)

    # Theoretical distribution:
    # Zombie ~ Geometric(p=w), mean = 1/w
    # For small w, this looks like Exp(λ) with λ ≈ -log(1-w)
    λ = -log(1 - w)

    # Plot histogram vs. exponential density
    plt = histogram(samples; bins=50, normalize=:pdf, alpha=0.5,
                    label="Zombie gaps",
                    xlabel="t", ylabel="density",
                    title="Zombie gap vs. Exp(λ), w=$w")
    ts = range(0, maximum(samples); length=200)
    plot!(plt, ts, pdf.(Exponential(1/λ), ts); lw=2, label="Exp(λ), λ=$(round(λ,digits=3))")
    display(plt)

    println("Zombie gap mean ≈ $(mean(samples)) (theory geometric mean = 1/w = $(1/w))")
    println("Equivalent exponential rate λ = -log(1-w) = $λ")
    println("So the algorithm produces approx. Exp(λ) arrivals.")
end

# Run
main()
