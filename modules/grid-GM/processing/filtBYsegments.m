function datafilt = filtBYsegments(TimeTags, DataIn, FilterSettings)
% Filters DataIn in segments when time-tags have gaps larger than 500
%    seconds. 

%-- Debug check 
% [~, n] = size(DataIn); 
% if ~isequal(n, 3)
%     error("Incorrect parsed dimensions for DataIn"); 
% end

%--- Get segments where no gaps
Seg = find_segments(TimeTags(:,1)); data = cell([1, length(Seg)]); 

%--- Determine average sample rate
Fs = 1; %Assuming sample rate is 1

%--- Filter each segment
for i = 1:size(Seg, 1)
    if length(DataIn(Seg(i,1):Seg(i,2),:)) < 250
        data{i} = DataIn(Seg(i,1):Seg(i,2),:); % If length of segment < 50 do nothing
    else
    data{i} = gaussian_FIR(Fs, DataIn(Seg(i,1):Seg(i,2),:), FilterSettings.Filter_Type, ...
        FilterSettings.Filter_Cut_Offs, FilterSettings.Filter_Order); 
    end
end

%--- Compile vector
datafilt = []; 
for i = 1:length(data)
   datafilt = cat(1, datafilt, data{1,i});
end
end

%--- Function to find segments
function Seg = find_segments(timeArray)

[~, n] = size(timeArray); 
if ~isequal(n, 1)
    error("Incorrect parsed dimensions for time array"); 
end

SegEnd = find(diff(timeArray) > 500); 
SegEnd = cat(1, SegEnd, length(timeArray)); 

SegStart = zeros(length(SegEnd), 1); 
for i = 1:length(SegEnd)
    if isequal(i, 1)
        SegStart(i) = 1;
    else
        SegStart(i) = SegEnd(i-1) + 1; 
    end
end

Seg = [SegStart SegEnd]; 

end