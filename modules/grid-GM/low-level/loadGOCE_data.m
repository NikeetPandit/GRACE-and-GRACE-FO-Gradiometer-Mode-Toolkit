function data = loadGOCE_data(PathHome, PathData, GradFile, yr, mnts, frame)
%-- Function loads in compute_GM outputs stored in pathData and
%   concatenates the outputs based on year, mnts.

cd(PathData); 
DataTable = []; 
%--- Compiling data in range
for i = 1:length(mnts)
    %--- Read in file 
    try
        %--- Replacing blanket string with actual year/month to read in
        fileread = strrep(GradFile, '_YEAR_', strcat('_', num2str(yr(i)), '_')); 
        fileread = strrep(fileread, 'MONTH', num2str(mnts(i))); 
        fprintf("Reading in ... %s\\%s\n", PathData, fileread);

        %--- Concat array
         DataTable = cat(1, DataTable, (load(fileread).data_mnt)); 

    catch
        fprintf(2, "File Not Available: %s\\%s\n", PathData, fileread)
        continue
    end  
end

%--- Assign concatenated table to struct
data.coord = DataTable(:,1:2); 

%--- Assign gradients 
switch lower(frame)
    case 'grf'
        data.grad = DataTable(:,3:8); 

    case 'irf'
        data.grad = DataTable(:,9:14); 

    otherwise
        error("Invalid frame selection")
end
%--- Assign time
data.TIMEa = DataTable(:,end); 
data.TIMEb = data.TIMEa; 

cd(PathHome);
end

