function data = load_GGM1B(PathHome, PathData, GradFile, yr, mnts)
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
        cd(PathData)
        DataTable = cat(1, DataTable, (load(fileread).DataOut)); 

    catch
        fprintf(2, "File Not Available: %s\\%s\n", PathData, fileread)
        continue
    end  
end

%--- Assign concatenated table to struct
data.coord = [DataTable.Lon, DataTable.Lat]; %coordinates

%--- Assign Accelerations
data.ACCa = [DataTable.ACCax, DataTable.ACCay, DataTable.ACCaz]; 
data.ACCb = [DataTable.ACCbx, DataTable.ACCby, DataTable.ACCbz]; 

%--- Assign Position
data.POSa = [DataTable.POSax, DataTable.POSay, DataTable.POSaz]; 
data.POSb = [DataTable.POSbx, DataTable.POSby, DataTable.POSbz]; 

%--- Assign large gaps in SCA1B
data.SCA1Bgaps = DataTable.SCA1B_gaps; 

%--- Assign Time
data.TIMEa = DataTable.timeGPSa; 
data.TIMEb = DataTable.timeGPSb; 

%--- Assign Flags
try
    data.ACC_flags = DataTable.ACC_flags; 
catch
    data.ACC_flags = []; 
end
data.ACC_flags = []; 


cd(PathHome);
end

