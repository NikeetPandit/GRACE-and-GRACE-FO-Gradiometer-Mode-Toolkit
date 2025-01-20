%--- 1 is outlier 0 is not
% 0.5 is normal 
%
% In general, if an outlier is flagged in any of 3-D accelerometer components, 
%  all 3-D accelerometer accelerations are flagged. If an accelerometer measurement is flagged, 
%  10 seconds before are also flagged as outliers. At 

function ind_outlier_padded = find_jumps(Fs, ACC, thresh)
 

%--- Scaling padding number on either side by sample rate
PadNo = 20*Fs; 

%--- HP filter to ACC data to noise floor determined from PSD
Fc = 0.15/5; ACC = gaussian_FIR(Fs, ACC, 'hp', Fc, 1); 

%--- Use high-pass filters as "residuals" (seen to be normally dist) 5
res_mean = mean(ACC, 1); res_std = std(ACC, 1); %--- Determing bound of data to keep 
bound = [min(res_mean - res_std*thresh, [], 2) min(res_mean+res_std*thresh, [], 2)];
ind_outlier = max(ACC >= bound(2) | ACC <= bound(1), [], 2);

%--- Finding when outlier starts and outlier stops
a = cat(1, 0, diff(ind_outlier)); 

%--- Padding so N seconds before first detection of outlier is also outlier
ind_pre_pad_outlier = [find(a == 1) - PadNo find(a == 1)]; 
ind_pre_pad_outlier(ind_pre_pad_outlier(:,1) <= 1, 1) = 1; 

%--- Padding so N seconds after last detection of outlier is also outlier
ind_post_pad_outlier = [find(a == -1) find(a == -1) + PadNo]; 
ind_post_pad_outlier(ind_post_pad_outlier(:,2) >= length(a), 2) = length(a); 

%--- Concat. array of where pre and post padding outlier is done
ind_outlier_pad_cat = cat(1, ind_post_pad_outlier, ind_pre_pad_outlier);

ind_outlier_padded = zeros(length(a), 1); 
for i = 1:length(ind_outlier_pad_cat)
    ind_outlier_padded(ind_outlier_pad_cat(i,1):ind_outlier_pad_cat(i,2)) = 1; 
end

%--- Assembling total outlier array
ind_outlier_padded = logical(max([ind_outlier_padded, ind_outlier], [], 2));


end
