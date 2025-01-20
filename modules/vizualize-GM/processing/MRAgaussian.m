function [Zdecomp, levelsBK] = MRAgaussian(Z, res, levels)

% Z spacing must be 1 deg
if ~isequal(res, 0.1)
    X1 = -179:0.1:179;   Y1 = -89:0.1:89;
    X0 = -179:179; Y0 = -89:89; 
    Z = interp2(X0, Y0', Z, X1, Y1', 'spline'); 
end


% Performs a multi-resolution analysis using gaussian filtering

%--- Assign filter bank filtering based on dyadic sampling
UB = transpose(2.^(1:levels)); LB = cat(1, 1, transpose(2.^(1:levels-1))); 
levelsBK = [transpose(1:levels), LB, UB]; %--- Assigning level bookkeeping matrix

%--- Setting lambda array to bandpass
LB = deg2km(LB.*0.1); UB = deg2km(UB.*0.1);  
 

Zdecomp = cell([1, length(LB)]); 
for i = 1:length(UB)

    if i < 2
        order = 1; 
    elseif i < 6
        order = 5; 
    else
        order = 10; 
    end

    if     i == length(UB)
        Zdecomp{i} = gauss2D_filt(Z, 'lp', deg2km(0.1), UB(i), order);

    else
        Zdecomp{i} = gauss2D_filt(Z, 'bp', deg2km(0.1), [UB(i), LB(i)], order);

    end
end

%--- Flipping to associate to bookkeeping matrix
Zdecomp = flip(Zdecomp); 

%--- Removing SH 256-1024... too high for this application 
Zdecomp = Zdecomp(1:end-3); levelsBK = levelsBK(1:end-3, :); levelsBK(1,2) = 0; 

%--- 
end
