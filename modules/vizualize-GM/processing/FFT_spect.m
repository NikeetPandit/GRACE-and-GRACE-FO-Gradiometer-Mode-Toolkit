function [frequency, spectrum] = FFT_spect(x,y, varargin)
% FFT_spect computes a 1-sided power/amplitude spectrum estimate using FFT.
%
%   Inputs:
%   (1) x:  1-D evenly spaced time-tag array. Size [nx1]. 
%   (2) y:  Input data. Size [nxm]. Operates on each on input column independently.
%   Optional: 'amplitude': To return amplitude spectrum
%
%   Outputs:
%   (1) frequency: One-sided frequency array. Size [nx1]. 
%   (2) spectrum: One sided power spectrum in dB, where ref. power is max
%       magnitude response.
%   (3) if 'amplitude' is parsed, one sided amplitude spectrum is returned.
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Reading variable-input
amplitude = find(strcmpi(varargin, 'amplitude'), 1); 

%--- Debug checks 
[n, m] = size(x); [n1, m1] = size(y);
if ~isequal(m, 1) || m1 >= n1
    error("Dimensions of input data not correct. See documentation"); 
end  

% --- Preliminary Calculation 
N = length(y);        
r = 0:floor(N/2);  % One-side index

% --- Calc. one sided freq components
if n ~= 1
    Fs = mean(diff(x)); 
else
    Fs = 1./x; 
end
fs = 1./Fs; % average sample rate
df = fs/N;                % Frequency Change (df)
frequency = transpose(r.*df);        % Frequency for FFT

% --- Calc. one sided amp. components (mult. by 2)
if isreal(y)
    Y1 = (abs(fft(y))./N); 
else
    Y1 = (abs(y)./N); 
end

%--- Building output array
amp_pos = Y1(1:length(r), :); spectrum = [amp_pos(1, :); amp_pos(2:end-1,:)*2; ...
    amp_pos(end,:)];

%--- Returning amplitude/power spectrum estimate
if ~isempty(amplitude)
    return
else
    power = 20*log10(spectrum./max(spectrum)); 
    spectrum = power; 
end

end