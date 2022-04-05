function out = getIQData(in)

frameComplex = in;

I = permute(real(frameComplex), [2 1])';
Q = permute(imag(frameComplex), [2 1])';

frameReal = cat(2, I, Q)';

out = frameReal;
end

