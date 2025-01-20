function [data, ind] = read_ACT1A_thrustFREE(ID, Date, PathA, PathB, varargin)

%--- Reading in ACT1A data
[data, ind] = read_ACT1A(ID, Date, PathA, PathB, varargin{1}, varargin{2});

%--- Reading in ACC data
try
    dataACC = read_ACC1A(ID, Date, 'E:\DATA-PRODUCTS\GRACE-FO-1A\2018-2022', PathB, varargin{1}, varargin{2}); 
catch
    error("No ACC1A data product for requested day."); 
end

%--- Debug chek 
if ~isequal(data(:,1), dataACC(:,1))
    error("Time-tags of ACT1A and ACC1A data product are not equivalent for some reason"); 
end

%--- There is non-zero difference when data has thruster/phantom acceleration 
outlier = max(abs(dataACC(:,2:end) - data(:,2:end)) > 0, [], 2); 

%--- Setting those values to NaN
data(outlier,2:end) = NaN; 

%--- Interpolating thruster values to create "thruster free data-set"
data(:,2:end) = fillmissing(data(:,2:end), 'linear', 'SamplePoints', data(:,1)); 

%--- Hamepl filter 
[~, outlier] = hampel(data(:,2:end), 200, 4);

outlier = max(outlier, [], 2); 

%--- Setting those values to NaN
data(outlier,2:end) = NaN; 

%--- Interpolating thruster values to create "thruster free data-set"
data(:,2:end) = fillmissing(data(:,2:end), 'linear', 'SamplePoints', data(:,1)); 

%--- Transforming to GPS time
data(:,1) = timeOBC2GPS(data(:,1), ID, Date, PathB); 

end