%% 
function F = grid_GGM1B(inputs)

%--- Assign constants
X0 = -179:1:179;   Y0 = -89:1:89; 

%--- Load in data (either GGM1B or GOCE)
if contains(inputs.GradFile, 'GOCE')
    data = loadGOCE_data(inputs.Working_Directory, inputs.PathData, ...
        inputs.Processing_Folder, inputs.yrs, inputs.mnts, 'GRF');
elseif contains(inputs.GradFile, 'GRACE')
    data = load_GGM1B(inputs.Working_Directory, inputs.PathData, ...
        inputs.GradFile, inputs.yrs, inputs.mnts);
else
    error("Error404")
end

%--- Pre-process GGM1B before 
outputs = process_GGM1B(data, inputs); clear data;
N = size(outputs,2);

%--- Grid module 
for j = 1:N
    [~, ind] = rmoutliers(outputs{1,j}(:,3:5), "percentiles", [0.5 99.5]); 
    outputs{2,j+1} = sum(ind); 
    outputs{1,j} = outputs{1,j}(~ind,:); 
end

%--- Grid all components
F = cell(N, 6); 

for k = 1:N
    for j = 1:6
        %--- Grid data by binning and taking mean
        try
            F{k, j} = gridbin(outputs{1,k}(:,1), outputs{1,k}(:,2), outputs{1,k}(:,j+2), X0, Y0, @mean);
        catch
            F{k,j} = []; 
        end
    end
end

end