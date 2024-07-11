classdef GAPIDOptim
    properties
        geneNumber; 
        populationSize;
        lower_limit;
        upper_limit;
        population;
        crossoverRate;
        mutationRate;
        generationNumber;
    end
    
    methods
        function obj = GAPIDOptim(geneNumber, populationSize, lower_limit, upper_limit, generationNumber, crossoverRate, mutationRate)
            obj.geneNumber = geneNumber;
            obj.populationSize = populationSize;
            obj.lower_limit = lower_limit;
            obj.upper_limit = upper_limit;
            obj.crossoverRate = crossoverRate;
            obj.mutationRate = mutationRate;
            obj.generationNumber = generationNumber;
            obj.population = unifrnd(obj.lower_limit, obj.upper_limit, [obj.populationSize obj.geneNumber]);
        end
        %% Update Population
        function obj = updatePopulation(obj, newPopulation)
            obj.population = newPopulation;
        end

        %% Calculate Costs with ITAE method
        function Costs = ITAE(obj) % amaç fonksiyonu bunu minimize etmek istiyoruz.
            for i=1:obj.populationSize
                assignin('base', 'Kpid',obj.population(i,:));
                sim("GA_PID_Optimization.slx");
                costs(i,1) = ans.ITAE(length(ans.ITAE));
            end
            Costs = costs;
        end
        %% Calculate Cumulative Probs
        function cumulProbs = CalcCumulativeProbs(obj, costs)
            costs = 1./costs;   % Minimize etmek için tersini alıyoruz. Çünkü kullanacağımız rulet çarkı yöntemi maximize etme yöntemidir.
            probs = costs / sum(costs,1);
            cumulativeProbs(1,1) = probs(1,1);
            for i=2:length(costs)
                cumulativeProbs(i,1) = cumulativeProbs(i-1,1) + probs(i,1);
            end
            cumulProbs = cumulativeProbs ;
        end

        %% Selection 
        function midPop = selection(obj,cumulProbs)
           popselector = unifrnd(0, 1, [obj.populationSize 1]);
           for i=1:obj.populationSize 
                idx = find(popselector(i,1) < cumulProbs , 1); 
                pop(i,:) = obj.population(idx,:);
           end
           midPop = pop;
        end
        %% Crossover 
        function crossPop = crossover(obj, midPop)
            pairselector = randperm(obj.populationSize);
            for j=1:(obj.populationSize/2)
                idx_1 = pairselector(2*j-1);
                idx_2 = pairselector(2*j);
                first_parent = midPop(idx_1,:);
                second_parent = midPop(idx_2,:);
                crossProb = rand();
                if crossProb < obj.crossoverRate
                    crossPoint = unidrnd(obj.geneNumber-1);
                    tempGen = first_parent(crossPoint:end);
                    first_parent(crossPoint:end) = second_parent(crossPoint:end);
                    second_parent(crossPoint:end) = tempGen;
                    midPop(idx_1,:) = first_parent;
                    midPop(idx_2,:) = second_parent;
                end
            end
            crossPop = midPop;
        end
        %% Mutation
        function newPop = mutation(obj, crossPop)
            mutationProbs = unifrnd(0, 1, [obj.populationSize obj.geneNumber]);
            for i=1:obj.populationSize
                for j=1:obj.geneNumber
                    if mutationProbs(i,j) < obj.mutationRate
                        crossPop(i,j) = crossPop(i,j) + unifrnd(-1,1) * obj.mutationRate * (obj.upper_limit - obj.lower_limit);
                    end
                end
            end
            newPop = crossPop;
        end
    end
end

