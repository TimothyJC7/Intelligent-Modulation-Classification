classdef UCB < handle
    % This class contains an implementation of the UCB algorithm in the
    % form of an object that is associated with a set of actions that are
    % initialized using .mat files from which trained neural networks
    % associated with modulation classification can be loaded. Note that
    % this class depends on an associated "Action" class.
    
    properties
        actions
        lastAction
        cValue
        totalActions
    end
    
    methods
        function this = UCB(cValue, listOfNetworks, listOfFileNames)
            %   UCB: Construct an instance of this class
            %   listOfNetworkFiles should be a cell array of file names
            %   corresponding to .mat files in the current directory that hold 
            %   trained neural network data. Assumes that the stored
            %   networks can be found under the property "trainedNet"
            numNetworks = length(listOfNetworks);
         
            this.actions = cell(1,numNetworks);
            for i = 1:numNetworks
                this.actions{i} = Action(listOfNetworks{i},listOfFileNames{i});
            end
            this.cValue = cValue;
            this.totalActions = 0;
        end
        
        function reward = setLastReward(this,AvgDist)
            %   setLastReward Sets value of the last action based on the
            %   AvgDist given to the function. The value is calculated
            %   as the average of 1/AvgDist for each time
            %   the action is selected.
            reward = 1/AvgDist;
            this.lastAction.value = (this.lastAction.value + reward) / this.lastAction.N; %avg reward is value
        end
        
        function action = getNextAction(this)
            %   getNextAction calculates the action with the optimal upper
            %   confidence bound based on the UCB algorithm and returns
            %   that action.
            maxActionVal = 0;
            numActions = length(this.actions);
            for i = 1:numActions
                curAct = this.actions{i};
                if (curAct.N == 0)
                    timesSelected = 1;
                else
                    timesSelected = curAct.N;
                end
                
                curVal = curAct.value + (this.cValue * sqrt(log(this.totalActions)) / timesSelected);
                
                if (curVal >= maxActionVal)
                    action = curAct;
                    maxActionVal = curVal;
                end
            end
            
            this.totalActions = this.totalActions + 1;
            action.N = action.N + 1;
            this.lastAction = action;
        end
    end
end

