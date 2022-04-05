modulationTypes = categorical(["BPSK", "QPSK", "8PSK", ...
  "16QAM", "64QAM"]); %, "PAM4", "GFSK", "CPFSK"]);

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
rng(1235)
tic

rolloff = 0.35;
filtlen = 4;
digitalFilter = rcosdesign(rolloff, filtlen, sps);

numModulationTypes = length(modulationTypes);

transDelay = 50;
channel = [-0.005-.004i .009+.03i -.024-.104i .854+.520i -0.218+.273i .049-.074i -0.016+0.02i];
%channel = [-.154-.061i .533+.377i .657+.465i 1.856-1.168i -.114+1.1i -.132+1.055i -.637+.245i];
% MMA Parameters
delta = 1e-4;
numTaps = 7;

% stepSizes = [1e-8 1e-7 1e-6 5e-6 1e-5 5e-5 1e-4 5e-4 1e-3 1e-2];
% cValue = 1;

ConstellationsList = getConstellationsList(modulationTypes);
load('mixedMaritimeData2.mat')
%%
dataCA = {numModulationTypes,numFramesPerModType};
% load('rxSamplesCNN1.mat')
  for modType = 1:numModulationTypes
%       RLEqualizerError = 0;
%       eqUCB = UCB(cValue, stepSizes);
    fprintf('%s - Generating %s frames\n', ...
      datestr(toc/86400,'HH:MM:SS'), modulationTypes(modType))
    
    label = modulationTypes(modType);
    numSymbols = (numFramesPerModType / sps);
    dataSrc = helperModClassGetSource(modulationTypes(modType), sps, 2*spf, fs);
    modulator = helperModClassGetModulator(modulationTypes(modType), sps, fs);
    for p=1:numFramesPerModType
%         RLdelta = eqUCB.getNextAction().stepSize;
        

        rxSamples = mixedMaritimeData2{modType, p};
        frame = helperModClassFrameGenerator(rxSamples.', spf, spf, transDelay, sps);
        
        
%         % Generate random data
%         x = dataSrc();
%         
%         % Modulate
%         [y, origSyms] = modulator(x);
% %         y = rxSamplesCA_CNN{modType, p};
%         % Pass through independent channels
%         rxSamples = filter(channel,1,y);
%         rxSamples = awgn(rxSamples,7);
        
%         %Downsample before equalizing
%         rxSamples = upfirdn(rxSamples,digitalFilter,1,sps);
%         rxSamples = rxSamples(filtlen + 1:end - filtlen);
%         
%         subplot(2,1,1)
%         scatter(real(rxSamples),imag(rxSamples));
%         xlabel('Q');
%         ylabel('I');
%         title('Noisy IQ Plot');
     
        
% %             % MMA With Constellation Known
%             constellation = ConstellationsList(modType);
%             R_real = mean(real(constellation).^4)/mean(real(constellation).^2);
%             if(sum(abs(imag(constellation))) < .0001)
%                 R_imag = 0;
%             else
%                 R_imag = mean(imag(constellation).^4)/mean(imag(constellation).^2);
%             end
%             equalizedSyms = equalizeMMA(rxSamples.', delta, numTaps, R_real, R_imag);
           % equalizerError = getErrorCount(equalizerError, equalizedSyms, origSyms, modulationTypes(modType), sps);
            
%               % Equalize
%               % MMA With Constellation Unknown
%               R_real = mean(real(rxSamples).^4)/mean(real(rxSamples).^2);
%               R_imag = mean(imag(rxSamples).^4)/mean(imag(rxSamples).^2);
%               equalizedSyms = equalizeMMA(rxSamples.', delta, numTaps, R_real, R_imag);
              
%               subplot(2,1,2)
%         scatter(real(equalizedSyms),imag(equalizedSyms));
%         xlabel('Q');
%         ylabel('I');
%         title('Equalized IQ Plot');  
              
             % allSyms = [equalizedSyms,(rxSamples(end-numTaps:end)).'].';
              %Refilter after equalizing so the format is right
%               equalizedSamples = upfirdn(equalizedSyms,digitalFilter,sps).';
%         
           
%               
        % RL Equalizer Constellation Unknown
%         equalizedSyms = equalizeMMA(rxSamples.', RLdelta, numTaps, R_real, R_imag);
%         
%         while(any(isnan(equalizedSyms)))
%             eqUCB.setLastReward(1.0); % Calling NaN 100% error
%             RLdelta = eqUCB.getNextAction().stepSize;
%             equalizedSyms = equalizeMMA(rxSamples.', RLdelta, numTaps, R_real, R_imag);
%         end
%         
%         %Calculate and set SER as reward (note that this is inverted to
%         %calculate actual reward in the UCB method)
%         prevErr = RLEqualizerError;
%         RLEqualizerError = getErrorCount(RLEqualizerError, equalizedSyms, origSyms, modulationTypes(modType), sps);
%         ErrChg = RLEqualizerError-prevErr;
%         thisSER = ErrChg/(spf/sps);
%         eqUCB.setLastReward(thisSER);
        %
      
%       
%       % Remove transients from the beginning, trim to size, and normalize
%       frame = helperModClassFrameGenerator(equalizedSyms.', spf, spf, transDelay, sps);
      
      % Remove transients from the beginning, trim to size, and normalize
%       frame = helperModClassFrameGenerator(rxSamples, spf, spf, transDelay, sps);
      
      dataCA{modType,p} = getIQData(frame);
    end
  end



%%
dataInfo = [numModulationTypes numFramesPerModType];
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
    "LearnRateDropFactor",0.9, ...
    "LearnRateDropPeriod",5, ...
    'ValidationData',{validData,validLabels}, ...
    'ValidationFrequency',validationFrequency);


numModTypes = numel(modulationTypes);
InputSize = 2;
layers = [
  sequenceInputLayer(InputSize)
  gruLayer(165,'OutputMode','sequence')
  reluLayer
  dropoutLayer(0.3)
  gruLayer(165,'OutputMode','Last')
  reluLayer
  dropoutLayer(0.3)
  fullyConnectedLayer(numModTypes)
  softmaxLayer
  classificationLayer
  ];

%%
trainedHFGRU = trainNetwork(trainData,trainLabels,layers,options);
%%
save('C:\Users\celynjacobs\Documents\MATLAB\FixedChannel_RL_EQ_NN\trainedGRU_128spf.mat','trainedGRU');
%%
rxTestPred = classify(trainedHFGRU,testData);
testAccuracy = mean(rxTestPred == testLabels);
disp("Test accuracy: " + testAccuracy*100 + "%")

figure
cm = confusionchart(testLabels, rxTestPred);
cm.Title = 'Confusion Matrix for Test Data';
cm.RowSummary = 'row-normalized';
cm.Parent.Position = [cm.Parent.Position(1:2) 740 424];

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
    
    B = 1;
    for i = 1:B
        for k=1:numSymbols-numTaps-1
        y_k = y(k:k+numTaps-1).'; 
        z_k=estimated_c.'*y_k;
        e_k= real(z_k)*(R_real - real(z_k)^2) + 1i * imag(z_k) * (R_imag - imag(z_k)^2);
        estimated_c=estimated_c+delta*e_k.*conj(y_k);
        end
    end

    for k=1:numSymbols-numTaps-1
        y_k = y(k:k+numTaps-1).'; 
        z_k=estimated_c.'*y_k;
        %e_k= real(z_k)*(R_real - real(z_k)^2) + 1i * imag(z_k) * (R_imag - imag(z_k)^2);
       % estimated_c=estimated_c+delta*e_k.*conj(y_k);
        equalizedSyms(k) = z_k;
    end
 end
 
 function errCount = getErrorCount(curErrCount, equalizerOutput, originalSignal, modType, sps)
    
    errCount = curErrCount;
    
    demodulatedSignal = demodulate(modType, equalizerOutput.', sps);
    signalLength = length(demodulatedSignal);
    
    for i = 1:signalLength
        decodedSymbol = demodulatedSignal(i);
        
        realDif = abs(real(decodedSymbol) - real(originalSignal(i)));
        imagDif = abs(imag(decodedSymbol) - imag(originalSignal(i)));
        tolerance = 0.01;
        
        if (realDif > tolerance || imagDif > tolerance)
            errCount = errCount + 1;
        end
    end
end