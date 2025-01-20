function function_return = GGM3B_inputs(inputs_in)
warning('on', 'all');
    switch nargin 
        case 0
            function_return = struct('Working_Directory', {},  'WaveLen', {}, ...
              'Compute_Start_Date', {}, 'Compute_End_Date', {}, 'Debug_Mode', {}, ...
              'Processing_Month', {}, 'GGM2B_data_path', {}, 'Skip_Folder', {}, ...
              'Processing_Folder', {}, 'Asc_Tracks', {}, 'Dec_Tracks', {}, 'All_Tracks', {}, ...
              'GM_output_mnts', {}, 'OutputType', {}, 'GradDIR', {}, 'CMlim', {}, ...
              'MRAlevels', {}, 'Coord', {}); 
        case 1
    
        %--- Throwing error messages if incorrect inputs are parsed
        if ~isempty(inputs_in.Compute_End_Date) && inputs_in.Compute_Start_Date > inputs_in.Compute_End_Date
            error("End computing date cannot be before start computing date."); 

        elseif ~isempty(inputs_in.Asc_Tracks) && (inputs_in.Asc_Tracks ~= 1 && inputs_in.Asc_Tracks ~= 0)
            error("To seperate gridded solutions to ascending tracks only, input must be logical 1."); 

        elseif ~isempty(inputs_in.Dec_Tracks) && (inputs_in.Dec_Tracks ~= 1 && inputs_in.Dec_Tracks ~= 0)
            error("To seperate gridded solutions to descending tracks only, input must be logical 1.");     

        elseif isempty(inputs_in.GGM2B_data_path)
            error("Must specify GGM2B_data_path."); 
            
        elseif isempty(inputs_in.OutputType) || (strcmpi(inputs_in.OutputType, 'matlab') && strcmpi(inputs_in.OutputType, 'gmt'))
            error("Must select either MATLAB or GMT to output data for visualization."); 
        
        elseif isempty(inputs_in.GradDIR)
            error("Must input gradient direction(s) to output"); 

        elseif strcmpi(inputs_in.OutputType, 'gmt') && isempty(inputs_in.CMlim)
            error("If GMT output is selected - must specify limits of data for color map."); 

        elseif strcmpi(inputs_in.OutputType, 'gmt') && (~isequal(length(inputs_in.CMlim), length(inputs_in.GradDIR)))
            error("Color map limits must be equiavelent to gradient direction specifications");

        elseif ~isequal(inputs_in.All_Tracks, 1) && ~isequal(inputs_in.Asc_Tracks, 1) ...
                && ~isequal(inputs_in.Dec_Tracks, 1)
            error("Must specify some track subset for plotting.");

        elseif ~isequal(length(inputs_in.GradDIR), 6)
            error("Grad Direction must have 6 elements"); 
        end

        %--- Checking to see if the input convention is correct
        check = fieldnames(GGM3B_inputs()); 
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
 