%--- Rotate data to a local ENU frame
function [output, data] = rotate_ENU(output, data)

%--- Determining azimith along satellite motion direction 
az = azimuth(output(1:end-1,2), output(1:end-1,1), ...
    output(2:end,2), output(2:end,1));

%--- Indexing data to shift
output = output(2:end,:); data.TIMEa = data.TIMEa(2:end); 

data.TIMEb = data.TIMEb(2:end); data.SCA1Bgaps = data.SCA1Bgaps(2:end);
data.ACCa = data.ACCa(2:end,:); data.ACCb = data.ACCb(2:end,:);

try
    data.ACC_flags = data.ACC_flags(2:end); 
catch
    data.ACC_flags = []; 
end

%--- Referencing gradient to a local ENU
output(:,3:8) = rotate_tensor(output(:,3:8), abs(my_rotz(az))); 

end


function DataOut = rotate_tensor(DataIn, R)
% -- R is along third dimension
% -- DataIn is [Vxx, Vyy, Vzz, Vxy, Vxz, Vyz] 

%--- Get 3x3xn gradient tensor from gradient components 
DataIn = get_grad_mat(DataIn); 

%--- Transform Accelerometer Measurements to ECI
DataOut = pagemtimes(pagemtimes(R, DataIn), pagetranspose(R));

%--- Get Grad Components
DataOut = get_grad_comp(DataOut);

end

function grad_components = get_grad_comp(grad)

Vxx = reshape(grad(1,1,:), [], 1); 
Vyy = reshape(grad(2,2,:), [], 1); 
Vzz = reshape(grad(3,3,:), [], 1); 
Vxy = reshape(grad(1,2,:), [], 1); 
Vxz = reshape(grad(1,3,:), [], 1); 
Vyz = reshape(grad(2,3,:), [], 1); 

grad_components = [Vxx Vyy Vzz Vxy Vxz Vyz]; 

end

function grad = get_grad_mat(grad_components)

Vxx = reshape(grad_components(:,1), 1, 1, []); 
Vyy = reshape(grad_components(:,2), 1, 1, []); 
Vzz = reshape(grad_components(:,3), 1, 1, []); 
Vxy = reshape(grad_components(:,4), 1, 1, []); 
Vxz = reshape(grad_components(:,5), 1, 1, []); 
Vyz = reshape(grad_components(:,6), 1, 1, []); 

grad = [Vxx Vxy Vxz; ... 
    Vxy Vyy Vyz; ...
    Vxz Vyz Vzz]; 

end


function R = my_rotz(angle_deg)
%-- MY_ROTZ creates a rotation matrix about the z-axis.

%--- Shaping angles, zeros, ones along third dimension 
angle_deg = reshape(angle_deg, 1, 1, []); 
my_zero = zeros(1, 1, length(angle_deg)); 
my_one = ones(1, 1, length(angle_deg)); 

%--- Consturcting rotation matrix about Z
R = [cosd(angle_deg), -sind(angle_deg), my_zero; sind(angle_deg)...
    cosd(angle_deg) my_zero; my_zero my_zero my_one]; 

end





























