classdef circulantMatrix < handle
% Circulant time-varying matrix processor  
%
% Template from: Sebastian J. Schlecht, Sunday, 29 December 2019
% Modified by:   Gian Marco De Bortoli, Tuesday, 20 February 2024
    properties
        filters = dfilt.df2;
        initMatrix = 0;
        initEigValues;
        currentEigValues;
        numberOfOutputs;
        numberOfInputs;
    end
    
    properties (Access = private)
        osc;
    end
    
    methods
        function obj = circulantMatrix(N, cyclesPerSecond, amplitude, fs, spread)

            % Initialize circulant matrix
            phi = eps + (pi-2*eps)*rand(1, ceil(N/2)-1);
            e = exp(1i*phi);
            if mod(N,2) == 0
                e = [1, e, -1, fliplr(conj(e))];
            else
                e = [1, e, fliplr(conj(e))];
            end
            obj.initMatrix = circulant(ifft(e, N), 1);
            assert(isreal(obj.initMatrix));


            % generate eigenvalue oscillators
            cyclesPerSample = cyclesPerSecond / fs;
            
            frequencySpread = 2*(rand(1,ceil(N/2)-1)-0.5) * spread + 1;
            amplitudeSpread = 2*(rand(1,ceil(N/2)-1)-0.5) * spread + 1;
            oscAmplitude = amplitude * pi/2;
            
            if mod(N,2) == 0
                obj.osc = circulantEvenComplexOscillatorBank(frequencySpread .* cyclesPerSample, amplitudeSpread .* oscAmplitude);
            else
                obj.osc = circulantOddComplexOscillatorBank(frequencySpread .* cyclesPerSample, amplitudeSpread .* oscAmplitude);
            end
            
            % channels
            obj.numberOfOutputs = N;
            obj.numberOfInputs = N;
            
        end
        
        function out = filter(obj,in)

            % update oscillators
            len = size(in,1);
            e = obj.osc.get(len);
            
            % number of fft
            N = obj.numberOfOutputs;

            % filtering
            in_evDomain = fft(in, N, 2);
            in_update = in_evDomain .* e;
            out = real(ifft(in_update, N, 2));

        end
        
    end
end

