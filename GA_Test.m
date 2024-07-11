clear all; clc;

ga = GAPIDOptim(3,200,0,1,50,0.70,0.08);

generation = 1;
bestSolution = inf;
while generation <= ga.generationNumber
    costs = ga.ITAE();
    if min(costs) < bestSolution
        bestSolution = min(costs);
        idx = find(costs == bestSolution, 1);
        bestParameters = ga.population(idx,:);
    end
    cumulProbs = ga.CalcCumulativeProbs(costs);
    midPopulation = ga.selection(cumulProbs);
    crossoverPopulation = ga.crossover(midPopulation);
    newPopulation = ga.mutation(crossoverPopulation);
    ga = ga.updatePopulation(newPopulation);
    generation = generation + 1;
end