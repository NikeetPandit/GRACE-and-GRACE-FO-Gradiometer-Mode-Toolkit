function gridded_outputs = GGM2B_monthly(inputs)

%--- Setting variable for load GGM1B function
GradFile = inputs.GradFile; yr = inputs.yrs; mnts = inputs.mnts; 

% Inputs: Struct, GradFile: "Blanket String", Year and Month of to grid

%--- Build variable which holds path of monthly GM_outputs
PathData = strcat(strrep(inputs.GM_Outputs_Directory,'world',''), 'Monthly_Sols\'); 

%--- Grid data
for i = 1:size(yr, 2)


%% --- Load process inputs
    data = load_GGM1B(inputs.Working_Directory, PathData, GradFile, yr(:,i), mnts(:,i)); 
       
%--- Proces loaded outputs
    outputs = process_GGM1MB(data, inputs); clear data;

%--- Gridding module
    gridded_outputs = grid_GGM1B(outputs);

end

%--- Change back to working directory 
cd(inputs.Working_Directory); 

end
