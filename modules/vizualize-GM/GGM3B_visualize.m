% Facade which calls the main visualize module to visualze gridded gradient data

function GGM3B_visualize(inputs)

%---- Checking validity of inputs
GGM3B_inputs(inputs); 

%--- Specifying input defaults if not specified
if isempty(inputs.MRAlevels)
    inputs(1).MRAlevels = 1:11; 
end

if isempty(inputs.Coord)
    inputs(1).Coord = [-179 179 -89 89]; 
end

%--- Assign variable of where compute_GM stored computations
Path = strcat(inputs.GGM2B_data_path, '\'); 

%--- Extracting folders from path
folders = struct2cell(dir(Path)); folders = folders(1,3:end); 

%--- Gridding all solutions in folder and subject to modification by if statement below
if isempty(inputs.Processing_Folder)
    
    if ~isempty(inputs.Skip_Folder)
        %--- Removing any folder that is inputted to be skipped
        for i = 1:length(folders)
            if isequal(folders{i}, inputs.Skip_Folder)
                folders{i} = []; 
            end
        end
    end
    folders = folders(~cellfun(@isempty,folders)); 
else

%--- Setting folders to the only desired folder to be computed
folders{1} = (inputs.Processing_Folder); temp = folders{1}; clear folders
folders{1} = temp;
end

for i = 1:length(folders) 
    
    %--- Generate pathout for each folder in path 
    PathOut = append(Path, folders{i}, '\'); 

    %--- Get path of monthly computations
    PathData = struct2cell(dir(append(PathOut, 'Monthly_Sols\*mat'))); 
    
    %--- Isolate gradient files
    GradFiles = PathData(1,:);

    %--- Bulding up string depending on file name in folder
    if     contains(GradFiles{1}, '_C_')
        ID = "C";  
    elseif contains(GradFiles{1}, '_B_')
        ID = "B";
    elseif contains(GradFiles{1}, '_D_')
        ID = "D"; 
    elseif contains(GradFiles{1}, '_A_')
        ID = "A";
    else
        ID = "Two Satellites";
    end

    %--- Creating folder to output gridded data to
    cd(PathOut); mkdir('plots'); 
    PathOutGrid = append(PathOut, 'plots', '\'); 
    inputs.GM_Outputs_Directory = PathOutGrid; 

    %--- Load in GradFile
    PathOut = append(Path, folders{i}, '\world\'); 

    %--- Get path of monthly computations
    GridFiles = ls(append(PathOut, '*mat')); 

    if size(GridFiles, 1) > 1
        error("More than one grid file in directory. Functionality not programmed"); 
    end
    
    %--- Extracting year, month in requested range
    if     ~isempty(inputs.Compute_End_Date) && ~isempty(inputs.Compute_Start_Date)
    
        %--- Getting subset of array which correspond to index
        [y, m] = ymd(get_dates(inputs.Compute_Start_Date, inputs.Compute_End_Date)); 

        %--- Extracting year, month, solution months, from GridFiles
        [y1, m1, asc, dec, all] = extractInfo(GridFiles);
        y1 = y1{1}; m1 = m1{1}; 
    
        %--- Index of 3-D gridded data which corresponds to year/months
        ind = min([ismember(y1, y); ismember(m1, m)], [], 1); ind = find(ind == 1); 
        ind = buffer(ind, inputs.GM_output_mnts); 

        if isempty(ind)
            error("Selected date range does not correspond to date range of gridded date."); 
        end
    
    elseif isempty(inputs.Compute_End_Date) && isempty(inputs.Compute_Start_Date)
    
        %--- Index of 3-D gridded data which corresponds to year/months
        %--- Extracting year, month, solution months, from GridFiles
        [y, m, asc, dec, all] = extractInfo(GridFiles);
        y = y{1}; m = m{1}; ind = []; 
    
    else
        error("Either parse in compute start date and end date, or none at all."); 
    end
    
    %---- Seperating into monthly averaged solutions 
    y = buffer(y, 1); 
    m = buffer(m, 1); 

    %--- Index of 3-D gridded data which corresponds to year/months
    if isempty(ind)
        ind = buffer(1:numel(y) - sum(y(:) == 0), size(y,1)); 
    end

    %--- Plotting tracks for whatever is gridded out unless specified
    tracks = [all, asc, dec]; 

    if ~isequal(inputs.All_Tracks, 1)
        tracks(1) = 0; 
    end
    if ~isequal(inputs.Asc_Tracks, 1)
        tracks(2) = 0; 
    end
    if ~isequal(inputs.Dec_Tracks, 1)
        tracks(3) = 0; 
    end
    
    %--- Plot data/output to GMS
    produce_map(inputs, GridFiles, y, m, tracks, ID, ind);
 
    %--- Change back to working directory 
    cd(inputs.Working_Directory); 
      
end

function [yr, mnt, asc, dec, all] = extractInfo(GridFiles)

temp = GridFiles; clear GridFiles; 
GridFiles{1} = temp; 

for j = 1:length(GridFiles)

    ind = strfind(GridFiles{j}, '-'); ind1 = strfind(GridFiles{j}, '_'); 
    y(j) = str2num(GridFiles{j}(ind(1)-4:ind(1)-1));
    m(j) =  str2num(GridFiles{j}(ind(1)+1:ind(2)-1));
    m1(j) =  str2num(GridFiles{j}(ind(3)+1:ind1(3)-1));
    y1(j) =  str2num(GridFiles{j}(ind(3)-4:ind(3)-1)); 

    try
        asc(j) = strfind(GridFiles{j}, "asc") > 0; 
    catch
        asc(j) = 0; 
    end
    try
        dec(j) = strfind(GridFiles{j}, "dec") > 0; 
    catch
        dec(j) = 0; 
    end
    if asc(j) == 0 && dec(j) == 0
        all(j) = 1; 
    else
        try 
            all(j) = strfind(GridFiles{j}, "all") > 0; 
        catch
            all(j) = 0; 
        end
    end

    mnts(j) =  str2num(GridFiles{j}((strfind(GridFiles{j}, 'all')+4):(strfind(GridFiles{j}, 'mnts')-1)));

%--- Load in dates
[y, m] = ymd(get_dates(datetime(y(j), m(j),1), datetime(y1(j), m1(j),1)));

%---- Seperating into monthly averaged solutions 
yr{j} = buffer(y, mnts(j)); 
mnt{j} = buffer(m, mnts(j)); 

end