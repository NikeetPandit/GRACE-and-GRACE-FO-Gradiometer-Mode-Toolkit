%---- Function to output GMT txt
% data is 1 deg from -179 to 179 -89 to 89 - G tag
% coord is coord to segment data to and output... if empty assumes G
% BPlevel is the level that is requested from MRA
% levelBK is the book-keeping matrix generated from MRAfunctions
% inputs is the structure which has the working directory to return 

%---- Function to plot data - for quick inspection    
function output_matlab(data, level, coord, titlestr, filename, OutputDir, BPlevel, WorkDir)

%--- Setting constants
coast = load('coastlines.mat'); 
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


%--- Plotting data
f = figure('visible', 'off'); 
set(f, 'Position', get(0, 'Screensize'));
imagesc('xdata', X1, 'ydata', Y1, 'cdata', data); colormap jet; ylim([min(Y1) max(Y1)]); cb = colorbar;

N = 5;  
%--- Setting limits of colorbar 
lim = round((mean(abs(data(:)))), 1, 'significant');
clim([-lim*N, lim*N]); 
%clim([-0.5  0.5]);

%--- adding coast line 
line(coast.coastlon, coast.coastlat, 'LineWidth', 2); xlim([coord(1) coord(2)]);  ylim([coord(3) coord(4)]); 

%--- Build up title/filename 
if length((ismember(BPlevel, 1:11))) < 11 || isequal(ismember(BPlevel, 1:11),0)
    for i = 1: size(level, 1)
        titlestr = append(titlestr); %,  ' (', (num2str(level(i,3))), '-', num2str(level(i,2)), ' SH)'
        %% 
        filename = append(filename,  '-', (num2str(level(i,3))), '-', num2str(level(i,2)));

    end
else
        titlestr = append(titlestr,  '-', (num2str(0)), '-', num2str(2048)); 
        filename = append(filename,  '-', (num2str(0)), '-', num2str(2048)); 

end

%---
filename = append(strrep(num2str(coord), ' ', '-'), '-', filename); 
filename = strrep(filename, '--', '-'); 
filename = strrep(filename, '--', '-'); 
filename = convertStringsToChars(filename);
%--- Setting title string parameters
title(titlestr, 'FontSize', 40); cb.Title.String = "Eotvos"; 

%--- Saving plot
cd('plots'); mkdir(OutputDir); cd(OutputDir); 
try
    saveas(f, filename(2:end), 'jpeg'); 
catch
    saveas(f, filename, 'jpeg'); 
end

%--- Changing back to working directory
cd(WorkDir); 

end
                