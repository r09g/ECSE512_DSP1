% ECSE 512 Term Project
% The Prediction Model LMS Algorithm
% Updated : 20191129
% Authors: Raymond Yang, Charbel Matta
% -------------------------------------------------------------------------
function [e,b,y] = predictionLMS(n_d,FIR_len,duration,step,signal)
%   
%   E = PREDICTIONLMS(N_D,FIR_LEN,DURATION,STEP,SIGNAL) returns the desired
%   signal after LMS processing. The filter follows the prediction model
%   and removes a narrowband interference from a wideband desired signal.
%   
%   N_D is the delay applied to the raw input for the LMS filter. A large
%   N_D contributes to the rapid decorrelation of the desired signal with
%   its delayed copy. 
% 
%   FIR_LEN is the length of the FIR filter or the number of weights for 
%   the LMS algorithm. A longer filter results in more computation but
%   better and more accurate cancellation.
%
%   DURATION is the length of the raw signal.
% 
%   STEP is the step size for the LMS algorithm. This is a tunable factor
%   which affects the magnitude of the update. A step size too small may
%   result in a slow converging rate, but more finely tuned filter
%   coefficients (weights). A step size too large may cause filter
%   coefficients to be coarsely tuned and poor performance of the filter.
%   It could also cause the coefficients to diverge and become unstable.
% 
%   SIGNAL is the raw signal, with mixed noise and desired input.
% 

    % parameter mapping
    num = FIR_len;
    u = step;
    x = signal;

    x_d = [zeros(n_d,1);x];
    y = zeros(length(duration),1); % interference signal
    e = zeros(length(duration),1); % interference - delayed noisy input
    b = zeros(num,length(duration)); % filter coefficients
    frame = zeros(num,1); % noisy input frame for filter processing

    for k = 1:duration
        % fill frame for filter processing
        frame(2:num,1) = frame(1:num-1,1);
        frame(1,1) = x_d(k,1);
        % LMS iteration
        % filter output (modelled interference)
        % frame built using already delayed input
        y(k,1) = b(:,k)' * frame;
        % compute difference between the undelayed original signal and
        % interference (output of adaptive filter), expected outcome is the
        % modelled desired signal
        e(k,1) = x(k,1) - y(k,1);
        % adjust filter coefficients based on the correlation between the
        % original undelayed noisy input signal and the modelled desired signal
        b(:,k+1) = b(:,k) + u.*e(k,1).*frame(:,1);
    end
    
end

