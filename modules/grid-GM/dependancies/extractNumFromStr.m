function [y, m] = extractNumFromStr(str)
% Function parses in cell of all gradiometer file outputs and extracts
% year, month of solution in an array of type doubele and datetime format.

%--- Debug check 
if class(str) ~= "cell"
    error("Input must be type cell."); 
end
n = length(str); 
%--- Converting all char arrays to string
for i = 1:n
    str{i} = convertCharsToStrings(str{i}); 
end
numArray = zeros(n, 2); 
%--- Extracting number 
for i = 1:n
numArray(i,:) = str2num(regexprep(str{i}, {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '})); %From Stephan Koehler
end

%--- Building up datetime array
dateArray = NaT(1, n); 
for i = 1:n
    dateArray(i) = datetime(numArray(i,1), numArray(i, 2), 1); 
end
dateArray = sort(dateArray); 

%--- Assigning year and month from sorted dateArray
[y, m] = ymd(dateArray); 

end