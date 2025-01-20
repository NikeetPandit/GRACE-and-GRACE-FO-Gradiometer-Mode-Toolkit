%--- Function to apply a time-shift to bring the trailing satellite into the
% airspace of the leading satellite, to be as close as possible constrained
% by some loss function. 

function [ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B] = apply_timeshift(ACC_A, ACC_B, SCA1B_A, ... 
    SCA1B_B, POS_IRF_A, POS_IRF_B, inputs)

%------------------------------------------------------------------------------------------------------------------
%Apply "Gradiometer System" For SINGLE SATELLITE OPERATION
if inputs.Num_Of_Satellites == 1

    %--- "Leading" and "Trailing" are both the same satellite
    ACC = ACC_A; POS_IRF = POS_IRF_A; SCA1B = SCA1B_A; 

    %--- Find the min approach between the "two" spacecraft
    shift = inputs.GMshift* round(avg_sample_rate(ACC_A(:,1))); 
    if isempty(shift)
        shift = 1; 
    end
    %--- Assign "leading" spacecraft measurements
    ACC_A = ACC(shift+1:end, :); POS_IRF_A = POS_IRF(shift+1:end, :); SCA1B_A = SCA1B(shift+1:end,:); 
    
    %--- Assign "trailing" spacecraft measurements
    ACC_B = ACC(shift:end-shift,:); POS_IRF_B = POS_IRF(shift:end-shift,:); SCA1B_B = SCA1B(shift:end-shift,:); 

%------------------------------------------------------------------------------------------------------------------
%% Apply "Gradiometer System" For DUAL SATELLITE OPERATION
elseif inputs.Num_Of_Satellites == 2  

    %
    %------------------------------------------------------------------------------------------------------------------
    %--- Find the min approach between the two spacecraft using algorithms specified by user
    
    %--- Loss funnction to find minimum distance is L-1 norm 
    if strcmpi(inputs.GMshift, 'norm')
    
        [ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B]...
            = min_norm(ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B);
    
    %--- Set a constant lag - for testing purpose
    else
        [ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B] ...
            = set_lag(ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B, inputs.GMshift); 
    end

else
    error("Invalid selection for gradient mode operation."); 
end
end


