clear all;
clc;
load('mixedMaritimeData2.mat');

modulationTypes = categorical(["BPSK", "QPSK", "8PSK", ...
  "16QAM", "64QAM", "PAM4"]);

numFramesPerModType = 10000;

percentTrainingSamples = 80;
percentValidationSamples = 10;
percentTestSamples = 10;

SNR = 30;
sps = 8;                % Samples per symbol
spf = 128;             % Samples per frame
symbolsPerFrame = spf / sps;
fs = 200e3;             % Sample rate
fc = [902e6 100e6];     % Center frequencies

channel = helperModClassTestChannel(...
  'SampleRate', fs, ...
  'SNR', SNR, ...
  'PathDelays', [0 1.8 3.4] / fs, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4, ...
  'MaximumClockOffset', 5, ...
  'CenterFrequency', 902e6);

rng(1235)
tic

numModulationTypes = length(modulationTypes);

channelInfo = info(channel);
transDelay = 50;
fileNameRoot = "frame";

dataCA = {numModulationTypes,numFramesPerModType};

  for modType = 1:numModulationTypes
    fprintf('%s - Generating %s frames\n', ...
      datestr(toc/86400,'HH:MM:SS'), modulationTypes(modType))
    
    label = modulationTypes(modType);
    numSymbols = (numFramesPerModType / sps);
    dataSrc = helperModClassGetSource(modulationTypes(modType), sps, 2*spf, fs);
    modulator = helperModClassGetModulator(modulationTypes(modType), sps, fs);
    for p=1:numFramesPerModType
     rxSamples = mixedMaritimeData2{modType, p};
     frame = helperModClassFrameGenerator(rxSamples.', spf, spf, transDelay, sps);
      
      dataCA{modType,p} = getIQData(frame);
    end
  end
  

  


dataInfo = [numModulationTypes numFramesPerModType];
[magPhaseData] = IQtoMagPhase(dataCA,dataInfo,spf);
splitPercentages = [percentTrainingSamples,percentValidationSamples,percentTestSamples];
[trainDatanLabels,validDatanLabels,testDatanLabels] = SplitnFormat(dataCA,modulationTypes,splitPercentages,dataInfo);

trainData = trainDatanLabels(:,1);
trainLabels = trainDatanLabels(:,2);
trainLabels = [trainLabels{:}]';

validData = validDatanLabels(:,1);
validLabels = validDatanLabels(:,2);
validLabels = [validLabels{:}]';

testData = testDatanLabels(:,1);
testLabels = testDatanLabels(:,2);
testLabels = [testLabels{:}]';

%%
trainingSize = length(trainLabels);
miniBatchSize = 128;
validationFrequency = round(floor(trainingSize/miniBatchSize));

options = trainingOptions("adam", ...
    "InitialLearnRate",0.001, ... 
    "MaxEpochs",50, ...
    "MiniBatchSize",miniBatchSize, ...
    "Plots","training-progress", ...
    "Verbose",false, ...
    "Shuffle","every-epoch", ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",1, ...
    "LearnRateDropPeriod",5, ...
    'ValidationData',{validData,validLabels}, ...
    'ValidationFrequency',validationFrequency);


numModTypes = numel(modulationTypes);
InputSize = 2;
numHiddenUnits = 128;
layers = [
  sequenceInputLayer(InputSize)
  
  lstmLayer(numHiddenUnits,'OutputMode','sequence','Name','Lstm')
  reluLayer('Name','relu1')
  gruLayer(numHiddenUnits,'OutputMode','Last','Name','Gru')
  reluLayer('Name','relu2')
  
  fullyConnectedLayer(numModTypes)
  softmaxLayer
  classificationLayer
  ];

trainedHFLSTMGRU = trainNetwork(trainData,trainLabels,layers,options);
%%
save('C:\Users\celynjacobs\Documents\MATLAB\SendingToSelf\trainedLSTMGRU_128.mat','trainedLSTMGRU');
%%
rxTestPred = classify(trainedHFGRU,testData);
testAccuracy = mean(rxTestPred == testLabels);
disp("Test accuracy: " + testAccuracy*100 + "%")

figure
cm = confusionchart(testLabels, rxTestPred);
cm.Title = 'Confusion Matrix for Test Data';
cm.RowSummary = 'row-normalized';
cm.Parent.Position = [cm.Parent.Position(1:2) 740 424];