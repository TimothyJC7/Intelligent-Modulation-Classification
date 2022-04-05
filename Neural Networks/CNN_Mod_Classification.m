clear all
modulationTypes = categorical(["BPSK", "QPSK", "8PSK", ...
  "16QAM", "64QAM", "PAM4"]);%, "GFSK", "CPFSK"]);
% modulationTypes = categorical(["16QAM" , "64QAM"]);

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

chanTypes = ["iturHFMQ" "iturHFMM" "iturHFMD"];

rng(1235)
tic

numModulationTypes = length(modulationTypes);

transDelay = 50;
%channel = [-0.005-.004i .009+.03i -.024-.104i .854+.520i -0.218+.273i .049-.074i -0.016+0.02i];
channel1 = [0.067+0.106i -0.226-0.966i];
channel2 = [0.006+0.019i 0.203-0.963i -0.040+0.169i];
channel3 = [0.235+0.146i -0.087-0.033i 1.036+1.588i -0.224-0.160i];
channel4 = [-0.078+0.276i -0.596-0.344i 0.640-1.734i -0.335+0.009i -0.334+0.062i];
channel5 = [0.275-0.516i -0.309+0.603i 1.577+0.948i 0.182+0.386i 0.239-0.198i -0.160+0.203i];
channel6 = [-0.154-0.061i 0.533+0.377i 0.657+0.465i 1.856-1.168i -0.114+1.100i -0.132+1.055i -0.637+0.245i];

listofChannels = [channel1 channel2 channel3 channel4 channel5 channel6];
%SNRs = [-10 -5 0 5 10 15 20];
SNRs = [0 5 10 15 20]; %want to see how it will affect accuracy

% MMA Parameters
delta = 1e-4;
numTaps = 7;
% taps = [2 3 4 5 6 7];
% UCBobj = UCB(0.1, numTaps); 

dataCA = {numModulationTypes,numFramesPerModType};
    %used to store new generated dataset
mixedMaritimeData2 = {numModulationTypes, numFramesPerModType};
%load('mixedMaritimeData2.mat')
ConstellationsList = getConstellationsList(modulationTypes); %!


channelSel = randi([1 6]);
  for modType = 1:numModulationTypes
    fprintf('%s - Generating %s frames\n', ...
      datestr(toc/86400,'HH:MM:SS'), modulationTypes(modType))
    
    label = modulationTypes(modType);
    numSymbols = (numFramesPerModType / sps);
    dataSrc = helperModClassGetSource(modulationTypes(modType), sps, 2*spf, fs);
    modulator = helperModClassGetModulator(modulationTypes(modType), sps, fs);
    i = 1;
    for p=1:numFramesPerModType
        %rxSamples = mixedMaritimeData2{modType, p};
        
        if(mod(p,1000) == 0)
            channelSel = randi([1 6]);
        end
        channel = listofChannels(channelSel);
        %SNR = randi([1 5]);
        SNR = SNRs(i);
        if(mod(p,2000) == 0)
            i = i + 1; %increment i every 1200 frames/modType 
        end 
       
%       
      % Generate random data
      x = dataSrc();
      
      % Modulate
      y = modulator(x);
      
      % Pass through independent channels
      rxSamples = filter(channel, 1, y);
      rxSamples = awgn(rxSamples, SNR); 
%       
      filtlen = 4;
      filterCoeffs = rcosdesign(0.35, 4, sps);
      rxSamples = upfirdn(rxSamples, filterCoeffs, 1, sps); %downsampling
      rxSamples = rxSamples(filtlen + 1:end - filtlen);
      
      %Equalizer with RL
      R_real = mean(real(rxSamples).^4)/mean(real(rxSamples).^2);
      R_imag = mean(imag(rxSamples).^4)/mean(imag(rxSamples).^2);
      equalizedSyms = equalizeMMA(rxSamples.', delta, numTaps, R_real, R_imag);
      
      equalizedSyms = upfirdn(equalizedSyms, filterCoeffs, sps); %upsampling
      
      mixedMaritimeData2{modType, p} = equalizedSyms;


      
      % Equalizer 
            % MMA With Constellation Unknown
%       R_real = mean(real(rxSamples).^4)/mean(real(rxSamples).^2);
%       R_imag = mean(imag(rxSamples).^4)/mean(imag(rxSamples).^2);
%       equalizedSyms = equalizeMMA(rxSamples.', delta, numTaps, R_real, R_imag);
      
      % Equalizer known
%     constellation = ConstellationsList(modType);
%     R_real = mean(real(constellation).^4)/mean(real(constellation).^2); %!
%     if(sum(abs(imag(constellation))) < .0001)
%         R_imag = 0;
%     else
%         R_imag = mean(imag(constellation).^4)/mean(imag(constellation).^2);
%     end
%     equalizedSyms = equalizeMMA(rxSamples.', delta, numTaps, R_real, R_imag);
      
      %Equalize
      %     if we get NaN values, generate a new action from UCB until we
      %     dont
      %Classify
                  
      %Set Reward Based on Classified Modulation

     % equalizedSyms = upfirdn(equalizedSyms, filterCoeffs, sps); %upsampling
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      %Remove transients from the beginning, trim to size, and normalize
      %allSyms = rxSamples;
      frame = helperModClassFrameGenerator(equalizedSyms.', spf, spf, transDelay, sps);
      
      dataCA{modType,p} = getImageIQData(frame);

    end
  end
save('C:\Users\huynhe\Desktop\FilesForEmily\mixedMaritimeData2.mat', 'mixedMaritimeData2');
dataInfo = [numModulationTypes numFramesPerModType];
  
%%
% [magPhaseData] = IQtoMagPhase(dataCA,dataInfo,spf);
splitPercentages = [percentTrainingSamples,percentValidationSamples,percentTestSamples];
[trainDatanLabels,validDatanLabels,testDatanLabels] = SplitnFormat(dataCA,modulationTypes,splitPercentages,dataInfo);

trainData = trainDatanLabels(:,1);
trainLabels = trainDatanLabels(:,2);
trainLabels = [trainLabels{:}]';
trainTable = table(trainData,trainLabels);

validData = validDatanLabels(:,1);
validLabels = validDatanLabels(:,2);
validLabels = [validLabels{:}]';
validTable = table(validData,validLabels);

testData = testDatanLabels(:,1);
testLabels = testDatanLabels(:,2);
testLabels = [testLabels{:}]';
testTable = table(testData,testLabels);


%%
trainingSize = length(trainLabels);
maxEpochs = 30;
miniBatchSize = 128; %was 256

validationFrequency = floor(trainingSize/miniBatchSize);
options = trainingOptions('sgdm', ...
  'InitialLearnRate',0.01, ...
  'MaxEpochs',maxEpochs, ...
  'MiniBatchSize',miniBatchSize, ...
  'Shuffle','every-epoch', ...
  'Plots','training-progress', ...
  'Verbose',false, ...
  'ValidationData',validTable, ...
  'ValidationFrequency',validationFrequency, ...
  'LearnRateSchedule', 'piecewise', ...
  'LearnRateDropPeriod', 9, ...
  'LearnRateDropFactor', 0.1);

numModTypes = numel(modulationTypes);
netWidth = 1;
filterSize = [1 sps];
poolSize = [1 2];
layers = [
imageInputLayer([1 spf 2], 'Normalization', 'none', 'Name', 'Input Layer')
  
  convolution2dLayer(filterSize, 16*netWidth, 'Padding', 'same', 'Name', 'CNN1')
  batchNormalizationLayer('Name', 'BN1')
  reluLayer('Name', 'ReLU1')
  maxPooling2dLayer(poolSize, 'Stride', [1 2], 'Name', 'MaxPool1')
  
  convolution2dLayer(filterSize, 24*netWidth, 'Padding', 'same', 'Name', 'CNN2')
  batchNormalizationLayer('Name', 'BN2')
  reluLayer('Name', 'ReLU2')
  maxPooling2dLayer(poolSize, 'Stride', [1 2], 'Name', 'MaxPool2')
  
  convolution2dLayer(filterSize, 32*netWidth, 'Padding', 'same', 'Name', 'CNN3')
  batchNormalizationLayer('Name', 'BN3')
  reluLayer('Name', 'ReLU3')
  maxPooling2dLayer(poolSize, 'Stride', [1 2], 'Name', 'MaxPool3')
  
  convolution2dLayer(filterSize, 48*netWidth, 'Padding', 'same', 'Name', 'CNN4')
  batchNormalizationLayer('Name', 'BN4')
  reluLayer('Name', 'ReLU4')
  maxPooling2dLayer(poolSize, 'Stride', [1 2], 'Name', 'MaxPool4')
  
  convolution2dLayer(filterSize, 64*netWidth, 'Padding', 'same', 'Name', 'CNN5')
  batchNormalizationLayer('Name', 'BN5')
  reluLayer('Name', 'ReLU5')
  maxPooling2dLayer(poolSize, 'Stride', [1 2], 'Name', 'MaxPool5')
  dropoutLayer(0.5)
  
  convolution2dLayer(filterSize, 96*netWidth, 'Padding', 'same', 'Name', 'CNN6')
  batchNormalizationLayer('Name', 'BN6')
  reluLayer('Name', 'ReLU6')
  
  averagePooling2dLayer([1 ceil(spf/32)], 'Name', 'AP1')
  dropoutLayer(0.5)
  
  fullyConnectedLayer(numModTypes, 'Name', 'FC1')
  softmaxLayer('Name', 'SoftMax')
  
  classificationLayer('Name', 'Output')
  ];

trainedHFCNN = trainNetwork(trainTable,layers,options);
%%
%save('C:\Users\Tjcsl\OneDrive\Documents\MATLAB\REU-HF\BankofNeuralNetworks\trainedHFCNN_128spf.mat','trainedHFCNN');
save('C:\Users\huynhe\Desktop\FilesForEmily\trainedCNN2.mat','trainedHFCNN');
%%
rxTestPred = classify(trainedHFCNN,testTable);
testAccuracy = mean(rxTestPred == testLabels);
disp("Test accuracy: " + testAccuracy*100 + "%")

% figure
% cm = confusionchart(testLabels, rxTestPred);
% cm.Title = 'Confusion Matrix for Test Data';
% cm.RowSummary = 'row-normalized';
% cm.Parent.Position = [cm.Parent.Position(1:2) 740 424];

 function equalizedSyms = equalizeMMA(y, delta, numTaps, R_real, R_imag)
    % Center Tap Initialization (assumes at least three taps)
    if(mod(numTaps,2) == 0)
        initWeights = [zeros(1,numTaps/2-1),1,zeros(1,numTaps/2)].';
    else
        initWeights = [zeros(1,floor(numTaps/2)),1,zeros(1,floor(numTaps/2))].';
    end
    estimated_c= initWeights;
    numSymbols = length(y);
    equalizedSyms = ones(1,numSymbols);
    equalizedSyms(1:end) = y(1:end);

    b = 1;
    for r=1:b %for equalizer convergence
        for k=1:numSymbols-numTaps-1
            y_k = y(k:k+numTaps-1).'; 
            z_k=estimated_c.'*y_k;
             e_k= real(z_k)*(R_real - real(z_k)^2) + 1i * imag(z_k) * (R_imag - imag(z_k)^2);
            estimated_c=estimated_c+delta*e_k.*conj(y_k);
            equalizedSyms(k) = z_k;
        end
    end
 end