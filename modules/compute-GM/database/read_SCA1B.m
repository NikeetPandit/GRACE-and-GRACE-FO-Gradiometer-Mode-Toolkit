function  [data, ind] = read_SCA1B(ID, Date, Path, varargin)
% read_SCA1B loads quaternion data from ECI to SRF for GRACE and GRACE-FO. 
%
%   See flip_SCA1B function for valid interpolation of SCA1B quaternions. 
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product. 
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%
%   Example: read_SCA1B("C", datetime(2020, 1, 1), 'C:\files', 'pad', 3)
%
%   Outputs:
%   (1) data: [time, a, b, c, d] where Quaternion = a + bi + cj, + dk. Type double. Size [nx5]. 
%   (2) ind:  [Start Index, End Index] for data of Date requested in output (1). Size [1x2]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

if isempty(varargin) 

    %--- Converting datetime obj to day 
    day = datestr(Date, 'yyyy-mm-dd'); 
    
    %--- Concatenate strings for file read
    
    if     any(strcmpi(ID, ["A", "B"]))
        GRACE = 1; % Logical array to denote GRACE mission
        file = strcat(Path, "\", "SCA1B_", day, "_", ID, "_", "02.dat");    
    
    elseif any(strcmpi(ID, ["C", "D"]))
        GRACE = 0; 
        file = strcat(Path, "\", "SCA1B_", day, "_", ID, "_", "04.txt");
    
    else
        error("Invalid GRACE or GRACE-FO ID. Try again.");
    end
    
    %--- Open file
    fid = fopen(file, 'r');
    
    %--- Find end of header
    if isequal(GRACE, 1)
        skip_rows = find_grace_header(fid); frewind(fid); % Resets pointer
    else
        skip_rows = find_gracefo_header(fid); frewind(fid); % Resets pointer
    end
    
    %--- Read in file 
    data = cell2mat(textscan(fid, '%f %*s %*f %f %f %f %f %*f %*[^\n]\n',  'HeaderLine', skip_rows, 'delimiter', ' ', 'ReturnOnError', 0));
    
    %--- Close file
    fclose(fid);

else
    try
        data = cell([1, 3]);

    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_SCA1B(ID, Date + days(i-2), Path); 
        end
    
    %--- Truncating data to padding amount specified
    [data, ind] = truncate_data2pad(data, varargin); 

    %--- GRACE-FO sometimes flips subsequent days of SCA1B data
    check = data;  % Performing difference/threshold outlier detection to undo this operation

    %--- Checking padding before requested date
    check(1:ind(1)-1,2:end) = -data(1:ind(1)-1, 2:end); 
    if isequal(sum(sum(diff(check(:,2:end)).^2) < sum(diff(data(:,2:end)).^2)), 4)
        data = check; 
    end

    %--- Checking padding after requested date
    check = data; 
    check(ind(2)+1:end,2:end) = -data(ind(2)+1:end, 2:end); 
    if isequal(sum(sum(diff(check(:,2:end)).^2) < sum(diff(data(:,2:end)).^2)), 4)
        data = check; 
    end

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        data = read_SCA1B(ID, Date, Path); 
    end
    
end    

end