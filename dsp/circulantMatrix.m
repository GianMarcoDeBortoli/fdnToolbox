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
        function obj = circulantMatrix(A, N, cyclesPerSecond, amplitude, fs, spread)

            % initialize circulant matrix
            obj.initEigValues = eig(A);
            obj.initMatrix = circulant(1/N * fft(obj.initEigValues), 1);

            % define oscillators for eigenvalues time-variation
            R = tinyRotationMatrix(N,1/fs);

            [v,e] = eig(R);

            cyclesPerSample = cyclesPerSecond / fs;
            
            frequencySpread = 2*(rand(1,N)-0.5) * spread + 1;
            amplitudeSpread = 2*(rand(1,N)-0.5) * spread + 1;
            
            % make conjugate pairs
            IDX = nearestneighbour(v,conj(v));
            amplitudeSpread = (amplitudeSpread(IDX) + amplitudeSpread) / 2;
            frequencySpread = (frequencySpread(IDX) + frequencySpread) / 2;
            complexConjugateSign = sign(angle(diag(e))).';
            oscAmplitude = complexConjugateSign * amplitude * pi/2;
            
            % make eigenvalue oscillators
            obj.osc = complexOscillatorBank( frequencySpread .* cyclesPerSample, amplitudeSpread .* oscAmplitude);

            
            % channels
            obj.numberOfOutputs = N;
            obj.numberOfInputs = N;
            
        end
        
        function out = filter(obj,in)

            % updated eigenvalues
            len = size(in,1);
            o = obj.osc.get(len);
            e = o .* obj.initEigValues';
            obj.currentEigValues = e(end,:)';

            % feedback processing
            % N = obj.numberOfOutputs;
            % rows = 1/N * fft(e, N, 2);
            % C = blockCirculant(rows, len, N);
            
            % output
            % out = sum(C .* in, 2);
            % out = squeeze(out);


            N = obj.numberOfOutputs;
            in_evDomain = fft(in, N, 2);
            in_update = in_evDomain .* e;
            out = ifft(in_update, N, 2);

        end
        
    end
end

