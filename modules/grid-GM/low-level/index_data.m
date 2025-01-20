function data =  index_data(data, index)
% Indexes data structure by some index to keep
data.ACCa = data.ACCa(index,:); 
data.ACCb = data.ACCb(index,:); 
data.coord = data.coord(index,:); 
data.POSa = data.POSa(index,:); 
data.POSb = data.POSb(index,:); 
data.TIMEa = data.TIMEa(index,:); 
data.TIMEb = data.TIMEb(index,:); 
data.SCA1Bgaps = data.SCA1Bgaps(index,:); 
try
    data.ACC_flags = data.ACC_flags(index,:); 
catch
    data.ACC_flags = []; 
end
end