% Example for time-varying matrices
%
% Process a musical sound with a time-varying FDN reverberation. Different
% options include slow and fast time-variation.
%
% Sebastian J. Schlecht, Saturday, 28 December 2019
clear; clc; close all;

rng(1);

% init source signal
fs = 48000;
impulse = zeros(2*fs,1);
impulse(1) = 1;
time = linspace(0,2,2*fs)';

% Define FDN
N = 4;
numInput = 1;
numOutput = 1;
inputGain = orth(randn(N,numInput));
outputGain = orth(randn(numOutput,N)')';
direct = zeros(numOutput,numInput);
delays = randi([750,2000],[1,N]);
feedbackMatrix = 0.8*randomOrthogonal(N);

%% Generate absorption filters
RT_DC = 1.5; % seconds
RT_NY = 0.5; % seconds

[absorption.b,absorption.a] = onePoleAbsorption(RT_DC, RT_NY, delays, fs);
zAbsorption = zTF(absorption.b, absorption.a,'isDiagonal', true); 


% Process input
modulationFrequency = 0; % hz
modulationAmplitude = 0.0;
spread = 0;

TVmatrix = timeVaryingMatrix(N, modulationFrequency, modulationAmplitude, fs, spread);
impulseResponse = processFDN(impulse, delays, feedbackMatrix, inputGain, outputGain, direct, 'inputType', 'mergeInput');    

% Plot
figure(1); hold on; grid on;

plot(time, impulseResponse);
xlabel('Time [seconds]')
ylabel('Amplitude')


%% Test: Script finished
assert(1 == 1)


