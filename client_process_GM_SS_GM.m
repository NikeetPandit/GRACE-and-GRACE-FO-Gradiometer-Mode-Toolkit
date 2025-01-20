% Example code to process one month of GRACE-C SS-GM GGM1B data product
restoredefaultpath; 
addpath(genpath('modules')); clearvars; warning('off', 'all');

inputs = GGM1B_inputs(); 
inputs(1).Working_Directory = pwd; 
inputs(1).Path_Out = []; % specify path
inputs(1).Path1B = [];   % specify path
inputs(1).Path1A = [];   % specify path

inputs(1).Compute_Start_Date = datetime(2021, 5, 1);
inputs(1).Compute_End_Date = datetime(2021, 5, 31);
inputs(1).Num_Of_Satellites = 1; 
inputs(1).Filter_Cut_Offs = [10^-4, 10^-1]; 
inputs(1).Filter_Type = 'bp';
inputs(1).GRACE_ID = "C";
GGM1B_compute(inputs);




