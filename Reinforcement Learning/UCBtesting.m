% File: UCBtesting.m
% Author: Celyn Jacobs
% Purpose: Testing UCB for integration with Neural Networks

clear;
echo off;

% parameters
numActions = 10;
numIterations = 100;
cValue = 1.1;

% initialization
definitelyNeuralNetworks = cell(1,numActions);
UCB = UCB(cValue, definitelyNeuralNetworks);

% testing
for i = 1:numIterations
    action = UCB.getNextAction;
    UCB.setLastReward(1/i);
end