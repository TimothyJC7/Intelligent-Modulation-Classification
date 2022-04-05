% File: demodulate.m
% Author: Celyn Jacobs
% Purpose: Demodulates signals modulated according to the functions in
% helperModClassGetModulator and returns the demodulated frame. NOTE THAT
% IN THIS FUNCTION, "DEMODULATE" MEANS ASSIGNING A RECEIVED SIGNAL TO THE
% NEAREST CONSTELLATION, NOT ACTUALLY RETURNING ITS ASSOCIATED NUMERIC
% VALUE.
function [demodulatedFrame, isDigital] = demodulate(modType, rawFrame, sps)
    siglength = length(rawFrame);
    digitalFilter = rcosdesign(0.35, 4, sps);

    demodulatedFrame = zeros(1, siglength);
    isDigital = 1;

    switch(modType)
        case "BPSK"
            %demodulating
            filteredFrame = filter(digitalFilter, 1, downsample(rawFrame,sps));
            bpskdemod = comm.BPSKDemodulator;
            bpskmod = comm.BPSKModulator;
            demodulatedFrame = bpskdemod(filteredFrame);
            demodulatedFrame = bpskmod(demodulatedFrame);
        case "QPSK"
            filteredFrame = filter(digitalFilter, 1, downsample(rawFrame,sps));
            demodulatedFrame = pskdemod(filteredFrame,4, pi/4);
            demodulatedFrame = pskmod(demodulatedFrame,4, pi/4);
        case "8PSK"
            filteredFrame = filter(digitalFilter, 1, downsample(rawFrame,sps));
            demodulatedFrame = pskdemod(filteredFrame, 8);
            demodulatedFrame = pskmod(demodulatedFrame,8); 
        case "16QAM"
            filteredFrame = filter(digitalFilter, 1, downsample(rawFrame,sps));
            demodulatedFrame = qamdemod(filteredFrame,16, 'UnitAveragePower', true);
            demodulatedFrame = qammod(demodulatedFrame,16, 'UnitAveragePower', true);
        case "64QAM"
            filteredFrame = filter(digitalFilter, 1, downsample(rawFrame,sps));
            demodulatedFrame = qamdemod(filteredFrame,64, 'UnitAveragePower', true);
            demodulatedFrame = qammod(demodulatedFrame,64, 'UnitAveragePower', true);
        case "PAM4"
            filteredFrame = filter(digitalFilter, 1, downsample(rawFrame,sps));
            deAmp = sqrt(mean(abs(pammod(0:3, 4)).^2));
            filteredFrame = deAmp * filteredFrame;
            demodulatedFrame = pamdemod(filteredFrame,4);
            demodulatedFrame = pammod(demodulatedFrame,4);
            demodulatedFrame = demodulatedFrame/deAmp;
        case "GFSK"  
            % NOTE: THE MODULATOR DOES A WEIRD ARITHMETIC TO THE INPUT
            % SIGNAL BEFORE MODULATING - WE DO NOT REVERSE HERE BUT THAT
            % MAY BE AN ERROR
            gfskDemod = comm.CPMDemodulator(...
               'ModulationOrder', 2, 'FrequencyPulse', 'Gaussian', ... 
               'BandwidthTimeProduct', 0.35, 'ModulationIndex', 1,'BitOutput', true, 'SamplesPerSymbol', sps); 
           gfskMod = comm.CPMModulator('ModulationOrder', 2, 'FrequencyPulse', 'Gaussian', ... 
               'BandwidthTimeProduct', 0.35,'BitInput', true, 'ModulationIndex', 1, 'SamplesPerSymbol', sps); 
           demodulatedFrame = gfskDemod(rawFrame);
           demodulatedFrame = gfskMod(demodulatedFrame);
           
        case "CPFSK" 
            % NOTE: THE MODULATOR DOES A WEIRD ARITHMETIC TO THE INPUT
            % SIGNAL BEFORE MODULATING - WE DO NOT REVERSE HERE BUT THAT
            % MAY BE AN ERROR
            cpfskDemod = comm.CPFSKDemodulator(...
                'ModulationOrder', 2,'ModulationIndex', 0.5,'BitOutput', true, 'SamplesPerSymbol', sps);
            cpfskMod = comm.CPFSKModulator(...
                'ModulationOrder', 2,'ModulationIndex', 0.5,'BitInput', true, 'SamplesPerSymbol', sps);
             demodulatedFrame = cpfskDemod(rawFrame); 
             demodulatedFrame = cpfskMod(demodulatedFrame); 
    end
end