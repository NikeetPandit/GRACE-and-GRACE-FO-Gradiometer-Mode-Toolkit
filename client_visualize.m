% Example code to process one month of GRACE-C SS-GM GGM3B data product
restoredefaultpath; addpath(genpath('modules')); clearvars; warning('off', 'all');

inputs = GGM3B_inputs(); 
inputs(1).Working_Directory = pwd; 
inputs(1).GGM2B_data_path = [];

inputs(1).GradDIR = [0 0 1 0 0 0]; 
inputs(1).Asc_Tracks = 1;
inputs(1).Dec_Tracks = 1; 
inputs(1).All_Tracks = 1; 
inputs(1).MRAlevels = 1:11; 
inputs(1).OutputType = 'MATLAB';


%% Compute
GGM3B_visualize(inputs)



