% Example code to grid one month of GRACE-C SS-GM GGM2B data product
restoredefaultpath; addpath(genpath('modules')); clearvars; warning('off', 'all');

inputs = GGM2B_inputs(); 
inputs(1).Working_Directory = pwd; cd(inputs.Working_Directory); 
inputs(1).GGM1B_data_path = []; 
inputs(1).Processing_Folder = [];

inputs(1).Compute_Start_Date = datetime(2010, 5, 1);
inputs(1).Compute_End_Date = datetime(2010, 6, 31);

%% Processing
GGM2B_grid(inputs); 


