function [gradient, dm_POS, dm_ACC] = grav_fun_compute(TimeA, TimeB, ACC_A, ACC_B, POS_A, POS_B, Filter_Specs)
%GRAV_FUN_COMPUTE is a utility to compute the gravitational tensor
%   given 3-D accelerationns and 3-D positions for leading (A) and trailing
%   (B) GRACE spacecraft. Accelerations and positions must be referenced to
%   the leading SRF. 
% 
%   To make a pseudo GRACE-GM mode reference frame (RF), the
%   frame which the gradient solutions are refenced to, input data
%   referenced to SRF-A is reflected to match the 1B definition of GRF for
%   GOCE mission. See handbook https://earth.esa.int/eogateway/documents/20142/37627/GOCE-Level-1b-Products-User-Handbook
%   Page 19., and page 109. This involves a reflection of X-SRF and Z-SRF
%   to match the frame of the accelerometers in GOCE's GRF, which resembles
%   then very closely to a local orbital reference frame (LORF). This
%   definition is found in the level 2 handbook. THE LORF does not equal
%   GRF for GOCE or GRACE-GM. 
%
%   Since the gradients [see line 66] are all reflected by a (-) factor,
%   the gradients are then defined positive in the direction negative of
%   the psuedo GRACE-GM mode RF. This is what GOCE does in their processing
%   for 1B data. 
%
%   For clarification, the leading and trailing here refers to the actual
%   leading and actual trailing of the spacecraft when they follow a
%   nominal trajectory. It DOES NOT refer to the leading and trailing of
%   this fictious scenario where a minization is found, fixing the leading
%   satellite and allowing the trailing satellite to fly. 
%   Since, in this scenario at the minimum point, the leading
%   can be trailing and vice versa and all differently in all 3-D
%   directions referenced to the leading SRF. 
%
%   Inputs:
%   (1) ACC_A, leading 3-D accelerations: [nx3] array interpreted as [X, Y, Z]
%   (2) ACC_B, trailing 3-D accelerations: [nx3] array interpreted as [X, Y, Z]
%   (3) POS_A, leading 3-D positions: [nx3] array interpreted as [X, Y, Z]
%   (4) POS_B, trailing 3-D positions: [nx3] array interpreted as [X, Y, Z]
%
%   *** Input units assumed to be in meters and assume to be refered to LEADING SRF ***
%
%   Outputs:
%   (1) gradient, [nx6] array given by [Vxx, Vyy, Vzz, Vxy, Vxz Vyz] in mE
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
[~, m] = size(ACC_A); [~, m1] = size(ACC_B); [~, m2] = size(POS_A); [~, m3] = size(POS_B); 
if ~isequal(m, 3) || ~isequal(m1, 3) || ~isequal(m2, 3) || ~isequal(m3, 3)
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Get Sample Rate
Fs = avg_sample_rate(TimeA(:,1)); Fs1 = avg_sample_rate(TimeB(:,1)); 
if ~isequal(Fs, Fs1)
    error("Sampling rate is not equivalent for ACC inputs."); 
end

%--- Reflect 3-D accelerations and 3-D positions to match accelerations in GOCE GRF
ACC_A = reflect_3D_data(ACC_A); %see function at line 84
ACC_B = reflect_3D_data(ACC_B); 
POS_A = reflect_3D_data(POS_A); POS_B = reflect_3D_data(POS_B); 

%--- Compute differential positions 
dm_POS = 0.5*(POS_A - POS_B); 

% %--- Compute differential accelerations
dm_ACC = 0.5*(ACC_A - ACC_B);

%--- Filtering Differential Positions 
Filt.Filter_Type = 'lp'; Filt.Filter_Cut_Offs = 10^-3.5; Filt.Filter_Order = 5; 
dm_POS = filtBYsegments(TimeA, dm_POS, Filt); 

%--- Filtering Differential accelerations 
if ~isempty(Filter_Specs.Filter_Cut_Offs)
    dm_ACC = filtBYsegments(TimeA, dm_ACC, Filter_Specs); 
end

%--- Removing shortest distances less than value
clipval = 0.1; 
for i = 1:3
    ind = dm_POS(:,i) > 0 & dm_POS(:,i) <= clipval; 

    dm_ACC(ind,i) = NaN; 
    ind = dm_POS(:,i) >= -clipval & dm_POS(:,i) < 0; 

    dm_ACC(ind,i) = NaN;
    
end

%--- Compute gradient tensor referenced to leading 
gradient = compute_grad(dm_ACC, (dm_POS)); % see function line 64

end

%--- Function to compute gradient 
function gradient = compute_grad(dm_ACC, dm_POS)

%--- Assign variables for easier notation
x_sep = dm_POS(:,1); y_sep = dm_POS(:,2); z_sep = dm_POS(:,3); 
acc_dx = dm_ACC(:,1); acc_dy = dm_ACC(:,2); acc_dz = dm_ACC(:,3); 

%--- Compute full symmetric gradient tensor
Vxx = -2*(acc_dx./x_sep); 
Vyy = -2*(acc_dy./y_sep); 
Vzz = -2*(acc_dz./z_sep); 
Vxy = -acc_dy./x_sep - acc_dx./y_sep; 
Vxz = -acc_dz./x_sep - acc_dx./z_sep; 
Vyz = -acc_dz./y_sep - acc_dy./z_sep;

%--- Compile output
gradient = ([Vxx, Vyy, Vzz, Vxy, Vxz Vyz].*1e12); 

end

%--- Reflecting X and Z components of input data
% Inputs:
%   (1): data, [nx3] array interpreted as [X, Y, Z]
function data =  reflect_3D_data(data)

[~, m] = size(data); 
if ~isequal(m, 3)
    error("Input dimensions are incorrect for what is being interpreted."); 
end

data(:,1) = data(:,1)*-1; 
data(:,3) = data(:,3)*-1; 

end
