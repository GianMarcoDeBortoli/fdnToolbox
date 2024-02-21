classdef circulantOddComplexOscillatorBank < handle
    % Array of complex oscillators for time-varying matrices
    %
    % Sebastian J. Schlecht, Friday, 17. January 2020
    properties
        cyclesPerSample
        amplitude
        FDNorder
    end
    
    properties (Access = private)
        state
    end
    
    methods
        function obj = circulantEvenComplexOscillatorBank(cyclesPerSample, amplitude)
            obj.cyclesPerSample = cyclesPerSample * 2*pi;
            obj.amplitude = amplitude;
            
            obj.state = zeros(size(amplitude));
        end
        
        function output = get(obj,len)
            
            ramp = (1:len)';
            time = obj.state + ramp .* obj.cyclesPerSample;
            angle = obj.amplitude .* sin( time );
            output = exp(1i*angle);

            vec1 = ones(len,1);
            output = [vec1, output, fliplr(conj(output))];
            
            obj.state = mod(time(end,:), 2*pi);
        end
    end
end