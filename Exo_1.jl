



#------------------------------------SM : Ch.1, p.44, problème 12 [en Julia]#------------------------------------#

using Random
using Plots

# Roll two fair six-sided dice
roll2(rng) = rand(rng, 1:6) + rand(rng, 1:6)

# Play one game of craps; return :WIN or :LOSE
function play_craps(rng)
    first = roll2(rng)
    if first == 7 || first == 11
        return :WIN
    elseif first == 2 || first == 3 || first == 12
        return :LOSE
    else
        point = first
        while true
            r = roll2(rng)
            if r == point
                return :WIN
            elseif r == 7
                return :LOSE
            end
        end
    end
end

# Parameters
N = 1000
rng = MersenneTwister(49)  # set seed for reproducibility; remove or change if you like

# Run trials
outcomes = [play_craps(rng) for _ in 1:N]
wins = count(==( :WIN), outcomes)
losses = N - wins
println("Wins: $wins  Losses: $losses  Win rate: $(round(wins/N, digits=4))")

# Plot histogram (bar chart of categories)
bar(["WIN","LOSE"], [wins, losses],
    legend = false,
    xlabel = "",
    ylabel = "Count",
    title = "Craps outcomes (N = $N)")

# Save the figure (optional)
savefig("/Users/xaviergagnon/Documents/Automne 2025/Finance Computationelle/TP1/Figs/craps_histogram.png")
println("Saved chart to craps_histogram.png")
