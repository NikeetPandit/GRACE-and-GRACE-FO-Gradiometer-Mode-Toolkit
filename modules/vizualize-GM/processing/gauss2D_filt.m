function Zfilt = gauss2D_filt(Z, filter, res, lambda, order, truncate)
% gauss2D_filter performs 2D gaussian filtering for gridded data. 
%   See gaussian_FIR for more information. 
%
%   Inputs:
%   (1) Z: 2D gridded data with spacing/resolution res
%   (2) filter: 'LP', 'HP', 'BP', 'BR'. Denotes low-pass, high-pass,
%   'band-pass', and 'band-reject filter, respectively.
%
%   (3) res: Spacing of input (1)
%   (4) lambda: Filtering wavelength(s)
%
%       If filter is 'HP', or 'LP', input must be scalar. 
%       If filter is 'BP', or 'BR', input must be size [nx2] where 
%       n2 > n1.
%
%   (5) Optional: N. Default is 1. Any integer > 1
%       N denotes how many times the input series is filtered. 
%   
%       The motiivation for this: 
%       A value of N = 10 will provide a sharper transition band than N = 1. 
%
%   Outputs:
%   (1) Zfilt:   Filtered signal.
%   (2) kernel: Impulse response of filter in time-domain. Use fftshift to center kernel.
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Determine filtering order based on inputs
switch nargin 
    case 5
        if     isempty(order)
            order = 1; 

        elseif order < 1
            error("Selected filter order is not valid."); 
        end

    case 4
            order = 1; 

end

%---
try 
    isempty(truncate);
catch
    truncate = []; 
end

switch lower(filter)

    
    case 'lp'
        Zfilt = lp_filt(Z, res, lambda, order, truncate); 

    case 'hp'
        Zfilt = Z - lp_filt(Z, res, lambda, order, truncate); 

    case 'br'
        Zfilt =  (Z - lp_filt(Z, res, min(lambda), order, truncate)) + ...
            lp_filt(Z, res, max(lambda), order, truncate);

    case 'bp'

        Zfilt =  (Z - lp_filt(Z, res, min(lambda), order, truncate)) + ...
            lp_filt(Z, res, max(lambda), order, truncate);

        Zfilt = Z - Zfilt; 

end

function Zfilt = lp_filt(Z, res, lambda, order, truncate)

filter = 'lp'; 

%--- Applying filtering columns of Z
Zfilt = gaussian_FIR(1./res, Z, filter, 1./lambda, order, truncate);

%--- Applying filtering on rows of Z 
Zfilt = gaussian_FIR(1./res, Zfilt', filter, 1./lambda, order, truncate);

%--- Transposing to return filtered result in proper orientation
Zfilt = transpose(Zfilt); 
