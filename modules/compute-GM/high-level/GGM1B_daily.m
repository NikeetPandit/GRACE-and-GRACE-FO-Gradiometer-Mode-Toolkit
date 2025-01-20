function output = GGM1B_daily(inputs, processing_day)
%% Preliminary
%--- Sets paths, variables, etc.
%------------------------------------------------------------------------------------------------------------------

%--- Determing which day tompute for based on inputs
switch nargin 
    case 1
        if      isempty(inputs.Processing_Day) && isesmpty(inputs.Compute_Start_Date)
            error("Must specify processing day."); 

        elseif  isempty(inputs.Processing_Day) && ~isempty(inputs.Compute_Start_Date)
            inputs(1).Processing_Day = inputs.Compute_Start_Date; 
        end
        
    case 2
        inputs(1).Processing_Day = processing_day; % If processing day is explicitly parsed

    otherwise
    error("Incorrect number of inputs parsed."); 
end

%--- Setting paths
disp(cat(2, 'Processing Day... ', datestr(inputs.Processing_Day))); warning('on'); 

%--- Setting current working directory
cd(inputs.Working_Directory); 

%--- Set 1B path based ond date
inputs =  setGRACEfolder(inputs); 


%--- Determine if date corresponds to GRACE or GRACE-FO
if inputs.Num_Of_Satellites == 2

mission = det_GRACEmission(inputs.Processing_Day); 

if      isequal(mission, 'GRACE')
    ID = ["A", "B"]; 
    
elseif  isequal(mission, 'GRACE_FO') 
    ID = ["C", "D"]; 

end
end

%% Compile and process daily inputs
%------------------------------------------------------------------------------------------------------------------
%--- Retreives, compiles, and processes data as necessary for GRACE gradiometery, and as specified by user-inputs

if inputs.Num_Of_Satellites == 2

    %--- Compiling data for GRACE A or C
    inputs.GRACE_ID = ID(1);
    [ACC_A, POS_IRF_A, SCA1B_A, ACC_DateEpochsA] = compile_daily_inputs(inputs); 
    
    %--- Compiling data for GRACE B or D
    inputs.GRACE_ID = ID(2);
    [ACC_B, POS_IRF_B, SCA1B_B, ACC_DateEpochsB] = compile_daily_inputs(inputs); 
    
    %--- See if two time-stamps same index leading and trailing ACC 
    N = min([length(ACC_A), length(ACC_B)], [], 2); % measurements are offeset by more than 50 seconds
    if any(ACC_A(1:N,1) - ACC_B(1:N,1) > 50 )       % quick debug check 
        output = []; 
        disp(cat(2, ['Missing lots of trailing or... ' ...
            'leading accelerometer data. Skipping Day... '], datestr(Date))); 
        return; 
    end
    
    %--- Determing leading and trailing spacecraft along flight motion 
    ID_A = find_lead_SC(POS_IRF_A, SCA1B_A); 
    
    %--- If GRACE "A" or GRACE-FO "C" is not leading... 
    if ~isequal(ID(1), ID_A) % switch variable assignment for software interpretation
    
        %--- Assigning a temporary cell variable 
        temp = {ACC_A, POS_IRF_A, SCA1B_A, ACC_DateEpochsA}; 
    
        %--- Assign "_B" variables to "_A" as to denote leading spacecraft
        ACC_A = ACC_B; POS_IRF_A = POS_IRF_B; SCA1B_A = SCA1B_B; ACC_DateEpochsA = ACC_DateEpochsB;
    
        %--- Assign "_A" variables to "_B" to denote trailing spacecraft
        ACC_B = temp{1}; POS_IRF_B = temp{2}; SCA1B_B = temp{3}; ACC_DateEpochsB = temp{4}; clear temp 
     
    end
    
    ACC_DateEpoch = [ACC_DateEpochsB(1) ACC_DateEpochsA(2)]; 
else
    
    %--- Compile data for selected GRACE or GRACE-FO ID
    [ACC, POS_IRF, SCA1B, ACC_DateEpoch] =  compile_daily_inputs(inputs);

    %--- Single satellite gradient operation is special case where... 
    ACC_A = ACC; ACC_B = ACC; clear ACC %"Leading" and "Trailing" are both the same satellite
    POS_IRF_A = POS_IRF; POS_IRF_B = POS_IRF; clear POS_IRF %Set variables appropiately 
    SCA1B_A = SCA1B; SCA1B_B = SCA1B;  clear SCA1B

end

%% Apply time-shift of trailing satellite to air-space of leading satellite
%------------------------------------------------------------------------------------------------------------------

[ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B] = apply_timeshift(ACC_A, ACC_B, SCA1B_A, ... 
    SCA1B_B, POS_IRF_A, POS_IRF_B, inputs);


%% Reference all data to leading satellite SRF at each epcoh 
%------------------------------------------------------------------------------------------------------------------

%--- Rotate all time-shifted trailing and leading measurements to leading SRF 
[ACC_A, ACC_B, POS_A_SRF, POS_B_SRF] = transform2leadSRF(ACC_A, ACC_B, SCA1B_A, SCA1B_B, POS_IRF_A, POS_IRF_B);


%% Format Daily Outputs
%------------------------------------------------------------------------------------------------------------------

%--- Compiling processed daily outputs
output = compile_daily_GGM1B(inputs, ACC_A, ACC_B, POS_A_SRF, POS_B_SRF, ACC_DateEpoch); 

%--- Changing directory back to working directory
cd(inputs.Working_Directory); 
end
