classdef Action < handle
    % Represents a potential action to be taken that is linked to a
    % specific neural network. Basically just a struct that holds updatable
    % properties corresponding to selecting that neural network when UCB is
    % applied to an Automatic Modulation Classification problem.
    
    properties
        value
        N
        associatedNN
        name
    end
    
    methods
        function this = Action(neuralNetwork, name)
            % Action constructor that requires an associated neural network
            % object
            this.value = 0;
            this.N = 0;
            this.name = name;
            this.associatedNN = neuralNetwork;
        end
    end
end

