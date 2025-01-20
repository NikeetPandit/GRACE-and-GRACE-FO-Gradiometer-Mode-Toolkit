%--- Seperate to descending tracks (assumes latitude is second index)
function dataOut = descending_tracks(dataIn)

dataOut = dataIn(diff(dataIn(:,2)) < 0,:); 

end