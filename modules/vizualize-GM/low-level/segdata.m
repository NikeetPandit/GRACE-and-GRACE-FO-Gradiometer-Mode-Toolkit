%--- Seperate to an area of coordinates (pads coord by 10 deg)
% coord = [lon1 lon2 lat1 lat2]

function [DataOut, ind] = segdata(DataIn, coord)

ind = DataIn(:,1) >= coord(1) & DataIn(:,1) <= coord(2) & DataIn(:,2) >= coord(3) & DataIn(:,2) <= coord(4); 
DataOut = DataIn(ind,:); 

end