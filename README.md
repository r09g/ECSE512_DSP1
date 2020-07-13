# ECSE512_DSP1
This is the term project for _ECSE 512 Digital Signal Processing 1_. The goal of this project was to use LMS and RLS algorithms to create an adaptive FIR filter that suppresses out a __narrowband noise__ in a __wideband desired signal__. The model used is commonly known as the prediction model, where both the exact desired signal and the noise is not known.

## Model
The prediction model is roughly in the form: <br>
<p align="center">
  <img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/predictionmodel.PNG">
</p>

## Algorithms: LMS
The least-mean-squares (LMS) approach is based on two fundamental ideas:
1. LMS uses ensemble statistics in theory; however, this is very difficult and requires heavy computations with real-time processing. Sampled ensemble statistics (instantaneous values) are used instead to provide an approximation. 
2. Each unit time is one gradient descent iteration.

Control of convergence rate and stability is done with only one scalar parameter: the step size

## Algorithms: RLS
The recursive-least-squares (RLS) is based on temporal statistics by considering past input values, with each of their effect weighed (or scaled) by a parameter known as the _forgetting factor_. The RLS utilizes two math techniques to simplify its filter coefficients update process: recursive updates and the _matrix inversion lemma (MIL)__. The sample autocovariance matrix is updated recursively and its inverse (used in computing the Kalman Gain Vector) is updated using the MIL. The RLS has rapid convergence but an order more computations compared to LMS.

Control of convergence rate and stability is done with the Kalman Gain Vector.

## Implementation
To fit our application, the input signal is delayed and fed to the filter, while the desired signal is the input signal without delay. The nature of the signal will cause the desired signal to rapidly decorrelate and the noise to be suppressed.

## Results
A sine wave interference signal of 2000 Hz is generated. A music sample is used as the desired signal. The generated input is:

<img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/desiredsgn.png">

With additive sine interference of 2000 Hz, the input signal is:

<img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/mixedinput.png">

The processed output is:

<img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/errorsgn.png">

The step size is set to a small value for demonstration purposes. The filter is adjusting itself to suppress more and more interference.

The filter output used to suppress the interference is:

<img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/adaptedsgn.png">

The filter is able to adapt and create an copy of the sine interference signal over time.

The 8092-point DFT of the input signal via FFT method:

<img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/Inputfft.png">

Note the peak at 0.09 pi rad/sec and the wideband nature of the desired signal.

The FIR filter's frequency response:

<img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/filterresp.png">

Note the peak (0 dB) at 0.09 pi rad/sec. Since Fs = 44.1 kHz, the frequency of the interference signal maps to roughly 0.09 pi rad/sec when sampled. The filter is trying to pass only the interference, so it may be used to cancel the interference. (Sidelobes are present due to its FIR nature).

The group delay of the FIR filter:

<img src="https://github.com/yanghaoqin/ECSE512_DSP1/blob/master/markdown/filtergrpd.png">


The LMS has better tracking abilities than the RLS for time-varying statistics.
