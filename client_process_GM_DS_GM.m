% Example code to process one month of GRACE-A and -B DS-GM GGM1B data product
restoredefaultpath; addpath(genpath('modules')); clearvars; warning('off', 'all');

inputs = GGM1B_inputs(); 
inputs(1).Working_Directory = pwd; 
inputs(1).Path_Out = [];
inputs(1).Path1B = [];

inputs(1).Num_Of_Satellites = 2; 
inputs(1).GRACE_ID = "A"; 
inputs(1).GMshift = 'norm'; 
inputs(1).Compute_Start_Date = datetime(2010, 5, 1);
inputs(1).Compute_End_Date = datetime(2010, 6, 31);

inputs(1).Filter_Cut_Offs = [10^-4, 10^-1]; 
inputs(1).Filter_Type = 'bp';
inputs(1).Interpolate_ACC = 1; 
GGM1B_compute(inputs);



