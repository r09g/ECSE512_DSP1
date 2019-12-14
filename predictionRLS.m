% ECSE 512 Term Project
% The Prediction Model RLS Algorithm
% Updated : 20191204
% Authors: Raymond Yang, Charbel Matta
% -------------------------------------------------------------------------
function [zeta,b,k_vec,y] = predictionRLS(n_d,FIR_len,duration,lambda,delta,signal)
%   
%   E = PREDICTIONRLS(N_D,FIR_LEN,DURATION,LAMBDA,DELTA,SIGNAL) returns the 
%   desired signal after RLS processing. The filter follows the prediction 
%   model and removes a narrowband interference from a wideband desired 
%   signal.
%   
%   N_D is the delay applied to the raw input for the RLS filter. A large
%   N_D contributes to the rapid decorrelation of the desired signal with
%   its delayed copy. 
% 
%   FIR_LEN is the length of the FIR filter or the number of weights for 
%   the RLS algorithm. A longer filter results in more computation but
%   better and more accurate cancellation.
%
%   DURATION is the length of the raw signal in terms of samples.
% 
%   LAMBDA is the weighing factor or the forgetting factor. This factor
%   controls the relative importance of the recent data points, allowing
%   the filter to track changing statistics in the input data. This affects
%   convergence of filter, ability of filter to track time-varying data,
%   and stability of coefficients.
% 
%   DELTA is required for the initialization of the sample autocovariance 
%   matrix, to ensure that the matrix is well behaved for a small n. As n
%   increases the effect of DELTA error decreases, due to the forgetting
%   factor. General guideline: delta > 100*(variance of input signal).
% 
%   SIGNAL is the raw signal, with mixed noise and desired input.
% 

    % parameter mapping
    num = FIR_len;
    x = signal;
    
    % setup
    y = zeros(duration,1);
    x_d = [zeros(n_d,1);x]; % delayed copy of raw signal
    b = zeros(duration,num); % filter coefficients
    k_vec = zeros(duration,num); % Kalman gain vector
    zeta = zeros(duration,1); % Error (desired signal)
    P = 1/delta * eye(num); % Sample autocovariance matrix (initialized)
    frame = zeros(num,1); % processing frame

    for k = 1:duration
        % obtain frame
        frame(2:num,1) = frame(1:num-1,1);
        frame(1,1) = x_d(k,1);
        % compute Kalman gain vector
        k_vec(k,:) = ((1/lambda)*P*frame) / (1 + (1/lambda)*frame'*P*frame);
        % filter output
        y(k,1) = b(k,:)*frame;
        % error signal (desired output)
        zeta(k,1) = x(k,1) - y(k,1);
        % filter coefficients update
        b(k+1,:) = b(k,:) + k_vec(k,:)*zeta(k,1); 
        % recursive update of the inverse of sample autocovariance matrix
        P = (1/lambda)*P - (1/lambda)*k_vec(k,:)*frame*P;   
    end
end

