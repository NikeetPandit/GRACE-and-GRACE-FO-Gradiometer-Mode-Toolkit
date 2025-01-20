function function_return = GGM2B_inputs(inputs_in)
    warning('on', 'all');
    switch nargin 
        case 0
            function_return = struct('Working_Directory', {},  'Filter_Type', ...
              {},  'Filter_Cut_Offs', {}, 'Filter_Order', {}, ...
              'Compute_Start_Date', {}, 'Compute_End_Date', {}, 'Debug_Mode', {}, ...
              'Processing_Month', {}, 'GGM1B_data_path', {}, 'Skip_Folder', {}, ...
              'Processing_Folder', {},  'Local_ENU', {}, 'GradFile', {}, 'yrs', {}, 'GM_output_mnts', {}); 

        case 1
    
        %--- Throwing error messages if incorrect inputs are parsed
        
        if      isempty(inputs_in.Working_Directory)
            error("Must specify current working directory.");

        elseif  ~isempty(inputs_in.Filter_Type) && isempty(inputs_in.Filter_Cut_Offs)
            error("Filtering type selected without any cut-off frequencies(s)."); 

        elseif ~isempty(inputs_in.Compute_End_Date) && inputs_in.Compute_Start_Date > inputs_in.Compute_End_Date
            error("End computing date cannot be before start computing date."); 

        elseif isempty(inputs_in.GGM1B_data_path)
            error("Must specify path of compute gradient output data."); 

        end
     
        %--- Checking to see if the input convention is correct
        check = fieldnames(GGM2B_inputs()); 
        ind = structfun(@isempty, inputs_in); 
        check_in = fieldnames(inputs_in); 
        check_in = check_in(~ind); 
        equil = 0; 
        for i = 1:length(check_in)
            for j = 1:length(check)
                equil = equil + isequal(check{j}, check_in{i}); 
            end
            if isequal(equil, 1)
               equil = 0; 
            else
                error("Incorrect parsing of inputs. Please ensure spelling matches the input structure convention exactly."); 
            end
        end

    end
end
 