function output = compile_daily_GGM1B(inputs, ACC_A, ACC_B, POS_A_SRF, POS_B_SRF, ACCDateEpochs)

%--- Assign input structure to variables
ID = inputs.GRACE_ID; Path1B = inputs.Path1B; 
Date = inputs.Processing_Day; ACCprod = GGM1B_inputs(inputs); 

%--- Determine if one or two mode operation 
[~, m] = size(POS_B_SRF); 
if m > 4
    twoMode = 1; 
else 
    twoMode = 0; 
end

[lat, lon] = get_GRACE_coord(ID, Date, Path1B, ACC_A(:,1));

%--- Find gaps in SCA1B data 
try
    if twoMode == 1 
        ind_SCA1B_gaps = find_SCA1B_gaps(2, Path1B, [ACC_A(:,1), ACC_B(:,1:3)]);

    else
        ind_SCA1B_gaps = find_SCA1B_gaps(1, Path1B, [ACC_A(:,1), ACC_B(:,1)], ID);
    end

catch
    output = []; disp(cat(2, ['Could not determine gaps in SCA1B data ...' ...
        'in find_SCA1B_gaps. Skipping day... '], datestr(timeGPS2dt(SCA1B(1,1)))))

    return
end

%--- Compile output array
if twoMode == 1
    temp = ACC_B; 
    ACC_B = [ACC_B(:,1) ACC_B(:,4:end)]; ACCBtimeyz = temp(:,2:3); 
    output = [lon, lat, ACC_A, ACC_B, POS_A_SRF(:,2:end), POS_B_SRF(:,4:end), ind_SCA1B_gaps, ACCBtimeyz]; 

else
    output = [lon, lat, ACC_A, ACC_B, POS_A_SRF(:,2:end), POS_B_SRF(:,2:end), ind_SCA1B_gaps]; 


end

%--- Finding indicies of padded output which corresponds to processing day
ACC_B((ACC_B(:,1) - ACCDateEpochs(1)) < 0, 1) = NaN;   % Setting time-tags before requested Date to NaN
ACC_A((ACC_A(:,1) - ACCDateEpochs(2)) > 0, 1) = NaN;   % Setting time-tags after requested Date to NaN
[~, ind1] = min(ACC_B(:,1) - ACCDateEpochs(1));        % Finding closest time-tag to requested Date in Date
[~, ind2] = min(abs((ACC_A(:,1) - ACCDateEpochs(2)))); % Makes output continuous and without boundary effects

%--- Isolating output to time stamp for Date without padding 
output = output(ind1-1:ind2,:);

%--- Downsampling to 1Hz if 10Hz to make more manageable
if isequal(inputs.Interpolate_ACC,1) || strcmpi(ACCprod, 'ACT1A')

    %--- Apply low-pass filtering before ..
    output(:,4:6) = gaussian_FIR(10, output(:,4:6), 'lp', 0.1); 
    output(:,8:10) = gaussian_FIR(10, output(:,8:10), 'lp', 0.1); 

    output = downsample(output, 10); 
end


%--- Outputting table and labelling columns for readability
if twoMode == 1
    output = array2table(output, 'VariableNames', {'Lon', 'Lat', 'timeGPSa', ...
    'ACCax', 'ACCay', 'ACCaz', 'timeGPSb', 'ACCbx', 'ACCby', 'ACCbz' ...
    'POSax', 'POSay', 'POSaz', 'POSbx', 'POSby', 'POSbz', 'SCA1B_gaps', 'timeGPSby', 'timeGPSbz'});
else

output = array2table(output, 'VariableNames', {'Lon', 'Lat', 'timeGPSa', ...
    'ACCax', 'ACCay', 'ACCaz', 'timeGPSb', 'ACCbx', 'ACCby', 'ACCbz' ...
    'POSax', 'POSay', 'POSaz', 'POSbx', 'POSby', 'POSbz', 'SCA1B_gaps'}); 
end
end

