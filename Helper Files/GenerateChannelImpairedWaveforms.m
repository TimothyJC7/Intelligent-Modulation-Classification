modulationTypes = categorical(["BPSK", "QPSK", "8PSK", ...
  "16QAM", "64QAM", "PAM4", "GFSK", "CPFSK", ...
  "B-FM", "DSB-AM", "SSB-AM"]);

numFramesPerModType = 2000;

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
dataDirectory = fullfile('C:\','Users','Tjcsl','OneDrive','Documents','MATLAB','REU-HF','BankofNeuralNetworks');
disp("Data file directory is " + dataDirectory)
fileNameRoot = "frame";

dataCA = {numModulationTypes,numFramesPerModType};

  for modType = 1:numModulationTypes
    fprintf('%s - Generating %s frames\n', ...
      datestr(toc/86400,'HH:MM:SS'), modulationTypes(modType))
    
    label = modulationTypes(modType);
    numSymbols = (numFramesPerModType / sps);
    dataSrc = helperModClassGetSource(modulationTypes(modType), sps, 2*spf, fs);
    modulator = helperModClassGetModulator(modulationTypes(modType), sps, fs);
    if contains(char(modulationTypes(modType)), {'B-FM','DSB-AM','SSB-AM'})
      % Analog modulation types use a center frequency of 100 MHz
      channel.CenterFrequency = 100e6;
    else
      % Digital modulation types use a center frequency of 902 MHz
      channel.CenterFrequency = 902e6;
    end
    for p=1:numFramesPerModType
      % Generate random data
      x = dataSrc();
      
      % Modulate
      y = modulator(x);
      
      % Pass through independent channels
      rxSamples = channel(y);
      
      % Remove transients from the beginning, trim to size, and normalize
      frame = helperModClassFrameGenerator(rxSamples, spf, spf, transDelay, sps);
      
      dataCA{modType,p} = getIQData(frame);
    end
  end

dataInfo = [numModulationTypes numFramesPerModType];