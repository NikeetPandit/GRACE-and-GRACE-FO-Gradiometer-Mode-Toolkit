function outputs1 = process_GGM1B(data, inputs)

%--- Gross outlier filter
data =  med_filt(data); %Hampel filter wrapper

%--- Computing gradient 
[gradient, dm_POS] = grav_fun_compute(data.TIMEa, data.TIMEb(:,1), ...
    data.ACCa, data.ACCb, data.POSa, data.POSb, inputs); data.POSa = []; data.POSb = []; 

%-- Compile output vector to grid 
output = [data.coord, gradient, dm_POS]; Flag1 = []; data.coord = []; clear gradient dm_POS 

%--- Rotate to ENU if selected
if      inputs.Local_ENU == 1
    [output, data] = rotate_ENU(output, data); %--- See inline function 
end

%--- Compile total flag vector
Flag = max([Flag1, data.SCA1Bgaps, data.ACC_flags], [], 2); 

%--- Remove flagged data from output
output = output(~Flag,:); clearvars -except output inputs OutliersRem ACCprod time

%--- Remove any flagged data based on overly short differential pos
output = rmmissing(output); 

%--- Constructing output with all-tracks/track seperation
outputs1{1} = output; % All tracks
outputs1{2} = ascending_tracks(output);  % Ascending tracks
outputs1{3} = descending_tracks(output); % Descending tracks

end

%--- Wrapper for hamepl filter length of entire input series
function data =  med_filt(data)

%--- Calculating diff POS/ACC
diffPOS = data.POSa - data.POSb; 

%--- Find median value in diff. POS/ACC
[~, ind] = hampel(diffPOS, length(diffPOS), 3);  ind = max(ind, [], 2);

%--- Indexing data to keep 
data = index_data(data, ~ind); 

end

