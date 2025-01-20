function index_shift = minDist_ellipsoid(pos_A, pos_B)
%MINDistSRF_xyz finds the closest approach of a trailing satellite to a fixed leading 
%   satellite on the ellipsoid. 
%
%   See the description of the algorithm for gradiometer for more details. 
%
%   Inputs:
%   (1) posA, [nx4] input matrix interpreted as [time, X, Y, Z]. Position
%       data for leading spacecraft in ITRF.
%   (2) posB, [nx4] input matrix interpreted as [time, X, Y, Z]. 
%
%   Outputs: 
%   (1) index_shift: indicies to shift data to the airspace of the leading
%       at closest approach, constrained by minimizing distance on ellipsoid. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Converting ECEF coordinates to lat, lon
[lat_A, lon_A] = ecef2geodetic(wgs84Ellipsoid('meter'), pos_A(:,2), pos_A(:,3),pos_A(:,4)); 
[lat_B, lon_B] = ecef2geodetic(wgs84Ellipsoid('meter'), pos_B(:,2), pos_B(:,3), pos_B(:,4)); 

%--- Assinging variable
coord_A = [lat_A, lon_A];
coord_B = [lat_B, lon_B]; 

%--- Isolating time vector from POS inputs
time_A = pos_A(:,1); 
time_B = pos_B(:,1); 

%--- Determining average sampling rate 
M_A = avg_sample_rate(time_A);
M_B = avg_sample_rate(time_B); 

if ~isequal(M_A, M_B)
    error("Dimensions of input data not correct. See documentation"); 
else
    M = M_A; clear M_A M_B
end

%--- Scaling sample rate by range to find minimization for
M1 = M * 45; 
M0 = M * 15; 

%--- Minimize 3D seperation in SRF

%--- Get loop variables
n = length(pos_A) - M1; 
index = [(1:n) + M0; (1:n) + M1]; 

%--- Finding index shift for min 3D distance (brute force)
ind_min = zeros(1,n); 

for i = 1:n

    %--- Extracting position range to minimize for trailing 
    search_minB = coord_B(index(1,i):index(2,i),:);

    %--- Finding shortest distance on ellipsoid 
    search_min = distance(search_minB(:,1), search_minB(:,2), coord_A(i, 1), coord_A(i,2), wgs84Ellipsoid('meter'));

    %--- Finding min 3D vector seperation in leading SRF based for XYZ
    [~, ind_min(i)] = min(abs(search_min(:,1)));  
  
end

%--- Extracting GPS time epochs where min. distance occurs by shifting trailing to leading
index_shift = (0:n-1) + M0 + ind_min;   

end


