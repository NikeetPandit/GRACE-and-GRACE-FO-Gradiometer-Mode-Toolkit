function GGM2B_grid(inputs)
% High level function to grid outputs of GM computations. 

%--- Checking inputs are valid
GGM2B_inputs(inputs); 
if isempty(inputs.GM_output_mnts)
    inputs.GM_output_mnts = 1;
end

%--- Assign variable of where compute_GM stored computations
Path = strcat(inputs.GGM1B_data_path, '\'); 

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

    %--- Extracting year, month in requested range
    if     ~isempty(inputs.Compute_End_Date) && ~isempty(inputs.Compute_Start_Date)
        [y, m] = ymd(get_dates(inputs.Compute_Start_Date, inputs.Compute_End_Date)); 

    elseif isempty(inputs.Compute_End_Date) && isempty(inputs.Compute_Start_Date)
        [y, m] = extractNumFromStr(GradFiles); % If no date range parsed extracting range from all gradiometer files

    else
        error("Either parse in compute start date and end date, or none at all."); 
    end
   
    %---- Seperating into monthly averaged solutions 
    y = buffer(y, inputs.GM_output_mnts); 
    m = buffer(m, inputs.GM_output_mnts); 

    %--- Bulding up string depending on file name in folder
    if     contains(GradFiles{1}, '_C_')
        GradFile = 'GRACE_C_GRAD_YEAR_MONTH.mat'; 
    elseif contains(GradFiles{1}, '_B_')
        GradFile = 'GRACE_B_GRAD_YEAR_MONTH.mat';
    elseif contains(GradFiles{1}, '_D_')
        GradFile = 'GRACE_D_GRAD_YEAR_MONTH.mat'; 
    elseif contains(GradFiles{1}, '_A_')
        GradFile = 'GRACE_A_GRAD_YEAR_MONTH.mat';
    elseif contains(GradFiles{1}, 'GOCE')
        GradFile = 'GOCEdata_YEAR_MONTH.mat';
    else
        GradFile = 'GRACE_TWOSAT_GRAD_YEAR_MONTH.mat'; 
    end

    %--- Creating folder to output gridded data to
    cd(PathOut); mkdir('world'); 
    PathOutGrid = append(PathOut, 'world', '\'); 
    inputs.GM_Outputs_Directory = PathOutGrid; 

    %--- Adding calculated value to input structure
    inputs.yrs = y; inputs.mnts = m; inputs.GradFile = GradFile; 
    inputs.PathData = strcat(strrep(inputs.GM_Outputs_Directory,'world',''), 'Monthly_Sols\'); 

    %--- Grid data
    gridded_outputs = grid_GGM1B(inputs); 
   
    %--- Changing to working directory
    cd(inputs.Working_Directory); 

    %---Write grid file out
    write_grid_file(inputs, y, m, gridded_outputs)
      
end
end
function write_grid_file(inputs, yr, mnts, gridded_outputs)

%---- Creating filename to write out
asc = "_asc_";
dec = '_dec_'; 
all = "_all_"; 
%--- Generating filename
if yr(end) == 0
    yr(end) = yr(end-1); 
    mnts(end) = mnts(end-1); 
end

filename = strcat("GM_grid_", num2str(yr(1)), "-", num2str(mnts(1)), ...
"-",num2str(yr(end)),"-", num2str(mnts(end)), asc, dec, all, ...
num2str(inputs.GM_output_mnts), "mnts");

filename = convertCharsToStrings(strrep(filename, "__", "_")); 
cd(inputs.GM_Outputs_Directory); 

inputs.Filter_Cut_Offs = reshape(inputs.Filter_Cut_Offs, 1, []); 

%--- Writing out 1 deg non filtered data/input strucutre
save(strcat(filename, ".mat"), 'gridded_outputs', '-v7.3');
writestruct(inputs, strcat(filename,".xml")); 
cd(inputs.Working_Directory);
end


























