function produce_map(inputs, GradFiles, yr, mnt, track, ID, index)

%--- Specifying constants
wavelen = inputs.WaveLen;
gradDir = inputs.GradDIR; 
coord = inputs.Coord; 
datalim = inputs.CMlim; 
output = inputs.OutputType; 
BPlevel = inputs.MRAlevels; 
GradStr_const = ["Vxx", "Vyy", "Vzz", "Vxy", "Vxz", "Vyz"]; 
track_str = ["All Tracks", "Ascending Tracks", "Descending Tracks"]; 
inputs(1).GM_output_mnts = 1; 

%--- Building up strings to be used later for plotting
TrackStr = string([1, 3]); 
for i = 1:3
    
    if track(i) == 1
        TrackStr(1,i) = track_str(i); 
    else
        TrackStr(1,i) = ''; 
    end
end

if strfind(GradFiles, "_NONE") > 0
    tag = '_none'; 
else
    tag = ''; 
end

mission = strrep(det_GRACEmission(datetime(yr(1,1), mnt(1,1), 25)), "_", " "); 

%--- Cycling through the year 

for i = 1
    
%--- Load in Data
    data = load(strcat('world\',GradFiles)).F;

%--- Index data
    data = data_ind_cell(data, index(:,i)); 

%--- Average Solutions 
    data = data_avg_cell(data);

%--- Inverse distance interpolation 
    data = data_interp_cell(data); 

%--- Filter all data in cell (see in-line fun)
    if ~isempty(wavelen)
        data = data_filt_cell(data, wavelen); 
    end

%---- Size data
    [mdim, ndim, ~] = size(data); 

%--- Plotting 
    for m = 1:mdim
        if isempty(data{m,1})
            continue; 
        end
        if track(m) == 0
            continue; 
        end
        for n = 1:ndim
            %--- If grad direction not wanted to be plotted... skip
            if gradDir(n) == 0
                continue; 
            end

            %---
            if contains(GradFiles, 'POD')
                data{m,n} = -data{m,n}; 
            end

            %-- Building up daterange string 
            DateStart = datetime(yr(1,i), mnt(1,i), 1); 
            if yr(end,i) == 0
                DateEnd =  datetime(yr(end-1,i), mnt(end-1,i),1);
            else
                DateEnd = datetime(yr(end,i), mnt(end,i),1);
            end

            DateStartStr = [ymd(DateStart), month(DateStart,'name')];
            DateEndStr = [ymd(DateEnd), month(DateEnd,'name')];

            %--- Get String Part of Label for Gradient Direction 
            GradStr = GradStr_const(n); 

            %--- Building up title String 
            titlestr = sprintf('%s %s: %s %s \n %s %s to %s %s', mission, ID, GradStr, TrackStr(m), DateStartStr{2}, num2str(DateStartStr{1}), ...
            DateEndStr{2}, num2str(DateEndStr{1}));


            %--- Building FileName of Image
            temp = convertStringsToChars(TrackStr(m)); 
            filename = strcat(datestr(DateStart), '_', datestr(DateEnd), '_', GradStr, '_', temp(1:3)); clear temp

            %--- Buidling output directory 
            outputdir = ['months_' num2str(size(yr,1)),'_', convertStringsToChars(GradStr_const(n)), ...
                tag, '_', convertStringsToChars(strrep(TrackStr(m), ' Tracks', ''))]; dataDECOMP = []; level_bk = ''; 

            %--- If any NaN smooth interpolate
            if sum(isnan(data{m,n}), 'all') > 0
                disp(sum(isnan(data{m,n}), 'all'))
                data{m,n} = fillmissing(data{m,n}, 'nearest'); 
            end

            %--- Do multi-resolution analysis if selected 
            if length((ismember(BPlevel, 1:11))) < 11 && ~isequal(ismember(BPlevel, 1:11),0)

                %--- Doing decomposition 
                [dataDECOMP, level_bk] = MRAgaussian(data{m, n}, 1, 11); 
             
    
            %--- Summing up selected levels 
                temp = zeros(size(dataDECOMP{1})); 
                indlevel = ismember(level_bk(:,1), BPlevel); 
                for k = 1:length(indlevel)
                    if indlevel(k) > 0
                        temp = dataDECOMP{k} + temp; 
                    end
                end
                data{m,n} = temp; dataDECOMP = []; 
                level_bk = level_bk(indlevel,:); 


            %--- No summing of levels, but wanting to plot all
            elseif BPlevel == 0
                [dataDECOMP, level_bk] = MRAgaussian(data{m, n}, 1, 11); 
            end

            %--- Output data to plot/txt for GMT
            switch lower(output)

                %--- Quick plots 
                case 'matlab'
                if isempty(dataDECOMP) 
                        output_matlab(data{m,n}, level_bk, coord, titlestr, filename, outputdir, BPlevel, pwd);
                     
                else
                    for ii = 1:length(dataDECOMP)
                        output_matlab(dataDECOMP{ii}, level_bk(ii,:), coord, titlestr, filename, outputdir, BPlevel, pwd);
                    end
                    
                end
   
                %--- Plots in GMT
                case 'gmt'
                if isempty(dataDECOMP) 
                        output_gmt(data{m,n}, datalim(n), level_bk, coord, filename, outputdir, BPlevel, pwd);

                else
                    for ii = 1:length(dataDECOMP)
                        output_gmt(dataDECOMP{ii}, datalim(n), level_bk(ii,:), coord, filename, outputdir, BPlevel(i,:), pwd);
                    end
                  
                end   

                otherwise
                    error("Invalid selection"); 
            
            end       
        end
    end 
end
%--
cd(inputs.Working_Directory); 

end
%--- Filter data based on wavelength 
function data_filt = data_filt_cell(data, wavelen)
[idim, jdim, kdim] = size(data); 
   for i = 1:idim
       for j = 1:jdim
           for k = 1:kdim
               if ~isempty(data{i,j,k})
                   %data_filt{i,j,k} = filt2(data{i,j,k}, deg2km(1), wavelen, 'lp');
                   data_filt{i,j,k} = gauss2D_filt(data{i,j,k}, 'lp', deg2km(1), 800);

               end
           end
       end
   end
end

%--- Average data in cells based on selectection
function data_avg = data_avg_cell(data)
[idim, jdim, kdim] = size(data); [M, N] = size(data{1,1,1}); 
for i = 1:idim
    for j = 1:jdim
        F = NaN(M,N); 
        for k = 1:kdim
            F = cat(3,F,data{i,j,k});
        end
        data_avg{i, j} = nanmean(F, 3); 
    end
end
end

%--- Index data to requested range from cell
function data_ind = data_ind_cell(data, ind)
[idim, jdim, ~] = size(data);
for k = 1:length(ind)
    for i = 1:idim
        for j = 1:jdim
            if ind(k) == 0
                continue;
            else
                data_ind{i,j,k} = data{i,j,ind(k)};
            end
        end
    end
end
end

%--- Inverse distance interpolation  
function data_interp = data_interp_cell(data)
wavelen = 1200; 
[idim, jdim, kdim] = size(data); 
   for i = 1:idim
       for j = 1:jdim
           for k = 1:kdim
               if ~isempty(data{i,j,k})

                   %--- Get size of cell
                   [M, N] = size(data{i,j,k}); 

                   %--- Apply 800km filtering to solution 
                   filt_val = reshape(filt2(data{i,j,k}, deg2km(1), wavelen, 'lp'), [], 1);

                   %--- Seeing where there is no value in bin
                   needToInterp = reshape(isnan(data{i,j,k}), [], 1); 

                   %--- Initializing array
                   out = zeros([numel(data{i,j,k}), 1]); 

                   %--- Reshaping the original data to column 
                   OG_shaped = reshape(data{i,j,k}, [], 1); 

                   %--- Placing original data back and then interpolated data where there is nothing  
                   out(needToInterp) = filt_val(needToInterp); out(~needToInterp) = OG_shaped(~needToInterp); 

                   %--- Outputting value 
                   data_interp{i,j,k} = reshape(out, M, N); ; 
                    
               end
           end
       end
   end
end








