%---- Function to output GMT txt
% data is 1 deg from -179 to 179 -89 to 89 - G tag
% data lim is bounds to truncate data for color lim
% coord is coord to segment data to and output... if empty assumes G
% BPlevel is the level that is requested from MRA
% levelBK is the book-keeping matrix generated from MRAfunctions
% inputs is the structure which has the working directory to return 
%X0 = -179:1:179;   Y0 = -89:1:89;  

function output_gmt(data, datalim, levelBK, coord, filename, OutputDir, BPlevel, WorkingDir)


if length(datalim) > 1 || isempty(datalim)
    error("Data limit must be one value"); 
end

X1 = coord(1):0.1:coord(2);   Y1 = coord(3):0.1:coord(4); 

%--- Smooth data to 0.1 degrees spline
if size(data, 1) == 1781
    X0 = -179:0.1:179;   Y0 = -89:0.1:89; 
else
    X0 = -179:1:179;   Y0 = -89:1:89; 
end
  
% %--- Trunacte data to coordinates
% ind_x = ismember(X0, X1); 
% ind_y = ismember(Y0, Y1); 

data = interp2(X0, Y0, data, X1, Y1', 'spline'); 
if isequal(BPlevel, 1:11)
    data = data - mean(data(:)); 
end

%--- Genearting the coordinates grid
[X1, Y1] = meshgrid(X1, Y1);

%--- Compiling data vector in xyz format
data = [reshape(X1, [], 1), reshape(Y1, [], 1), reshape(data, [], 1)]; data(:,3) = round(data(:,3),10); 

%--- Clipping data to limit
data = clip_data(data, datalim, -datalim); 

%--- Build up title/filename 
if length((ismember(BPlevel, 1:11))) < 11 || isequal(ismember(BPlevel, 1:11),0)
    for i = 1: size(levelBK, 1)
        filename = append(num2str(levelBK(1,1)), '_', (num2str(levelBK(i,2))), '_', num2str(levelBK(i,3)), '_', filename);
    end
else
        filename = append((num2str(0)), '_', num2str(2048), '_', filename); 
end

%data(data(:,1) < 0,1) = data(data(:,1) < 0,1) + 361 - 2.9; 


%--- Writing out text file
cd('plots'); mkdir(OutputDir); cd(OutputDir); writematrix(data, filename);

%--- Changing back to working directory
cd(WorkingDir); 

end

%--- Clip to some number by n and n1 assumes first two columns are lon, lat
%--- n is high clip and n1 is low clip
function data = clip_data(data, n, n1)
ind = data(:,3:end) > n; data(ind,3:end) = n;
ind = data(:,3:end) < n1; data(ind,3:end) = n1; 
end

                