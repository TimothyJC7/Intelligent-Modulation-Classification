function AD = getAD(ModType, distortedSignal, sps)
% Function getAD returns the average distance between the given distorted
% symbols and the constellations to which they are demodulated based on the
% given modType and sampling rate. Note that the demodulation function used
% here relies on the pulse-shaping and interpolation procedure given in
% helperModClassGetModulator.m

[demodulatedSignal, isDigital] = demodulate(ModType, distortedSignal, sps);
    if (isDigital)
        distortedSignal = filter(rcosdesign(0.35, 4, sps), 1, downsample(distortedSignal,sps));
    end
    
    sigLength = length(distortedSignal);
    ad = 0; 
    for s=1:sigLength
        dist = sqrt( ((real(demodulatedSignal(s)) - real(distortedSignal(s)))^2....
        + (imag(demodulatedSignal(s)) - imag(distortedSignal(s)))^2)); 
        ad = ad + dist; 
    end
    
    %minimum average distance for that frame is 
    AD = ad ./ (sigLength);
end

    
    