%% ECSE 512 Term Project
% Adaptive Filter with LMS and RLS
% Date : 20191129
% Authors: Raymond Yang, Charbel Matta
% -------------------------------------------------------------------------
clear; close all;
%% Parameter Specification
% Signal and filter characteristics
duration = 20; % length of signal in seconds
Fs = -1; % sample rate (enter -1 if unknown)
num = 20; % length of filter
n_d = 50; % samples to be delayed
atten = 0.2; % relative attenuation of input
freq = 2000; % frequency of sin in Hz
% LMS parameters
u = 0.00025;
% RLS parameters
lambda = 0.95; % forgetting/weighing factor
delta = 0.01; % initialization of P[n]
% System settings ---------------------------------------------------------
sound_sw = 1; % 0 for white noise and 1 for speech
noise_sw = 0; % 0 for deterministic sin and 1 for time-varying sin
alg_sw = 1; % 0 for LMS and 1 for RLS
verbose = 1; % 0 for no verbose; 1 for verbose
% -------------------------------------------------------------------------

%% Build Signals
if(verbose)
    disp('Building signal...')
end

if(~sound_sw)
    % white noise signal
    duration = Fs*duration;
    s = wgn(duration,1,0);
else
    % Import input signal
    if(Fs == -1)
        [y,Fs] = audioread('speech.wav');
        duration = duration * Fs;
        s = y(1:duration,1);
    else
        duration = duration * Fs;
        samples = [1,duration];
        [y,Fs] = audioread('speech.wav',samples);
        s = y(:,1);
    end
end

n = (0:duration-1)'/Fs;
s_max = max(abs(s));

% interference source
if(~noise_sw)
    i = s_max*sin(freq*2*pi*n); % deterministic sine interference signal
else
    % time-varying
    freq_incr = 3000; % overall increment in Hz
    f = linspace(0,freq_incr,duration); % generate linearly spread samples
    f = f + freq; % add base frequency
    i = s_max*sin(2*pi*f'.*n);
end

% build signals
x = i + atten*s; % mix signals
x_max = max(abs(x));
x = x./x_max; % normalize noisy signal amplitude

%% Processing Algorithm
if(~alg_sw)
    % LMS method
    if(verbose)
        disp('LMS Processing...')
    end
    tic
    [output,b,i_hat_lms] = predictionLMS(n_d,num,duration,u,x);
    toc
    if(verbose)
        disp('LMS Processing Complete')
    end
else
    % RLS method
    if(verbose)
        disp('RLS Processing...')
    end
    tic
    [output,b,k_vec,i_hat_rls] = predictionRLS(n_d,num,duration,lambda,delta,x);
    toc
    if(verbose)
        disp('RLS Processing Complete')
    end
end

%% View Results

% Learning Curve
error = zeros(duration,1);
temp = 0;
for k = 1:duration
    temp = temp + output(k,1)^2;
    error(k,1) = temp/k;
end

if(verbose)
    disp('Displaying Results...')
end

figure
plot(n,output) % plot the cancelled signal
title('Cancelled Signal')
xlabel('Time')
ylim([-1 1])
xlim([0 duration/Fs])
grid on
grid minor

figure
plot(n,atten*s) % plot the input signal
title('Desired Input Signal')
xlabel('Time')
ylim([-1 1])
xlim([0 duration/Fs])
grid on
grid minor

figure
plot(n,error) % plot the learning curve
title('Learning Curve')
xlabel('Time')
ylim([0 max(error)])
xlim([0 duration/Fs])
grid on
grid minor
