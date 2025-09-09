#------------------------------------SM : Ch.1, p.44, problème 13 [en Julia]#------------------------------------#

using Random

function simulate_hiv_test(trials::Int)
    positives = 0
    true_positives = 0
    for _ in 1:trials
        # We determine if the person has HIV 
        has_hiv = rand() < 0.03 # this returns True if we are below 0.03 else False. This replicates the probability of having HIV since the rand() function chooses a number between (0,1) uniformally

        if has_hiv
            test_positive = rand()< 0.98 # Because the test is 98% accruate, there is a 98% chance that they truly have hiv
        else
            test_positive = rand() < 0.02 
        end
        if test_positive
            positives += 1
            if has_hiv
                true_positives += 1
            end
        end
    end
    if positives == 0
        return 0.0  # no positives at all → probability undefined
    else
        return true_positives / positives
    end
end

prob_estimate = simulate_hiv_test(100000000)
println("Estimated probability that a person with a positive test has HIV: ", prob_estimate)

