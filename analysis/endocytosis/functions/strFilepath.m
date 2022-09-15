%%% Returns a proper filename from the input values
function [filename] = strFilepath(filenumber, filenameEnding, filepath, timepointindex, filenumberindex)
    timepoint = timepointindex(filenumber);
    if timepoint < 1
        timepoint = timepoint*60;
        filenamemid = 'min_Image';
    else
        filenamemid = 'h_Image';
    end
    timepoint = num2str(timepoint);
    groupnumber = num2str(filenumberindex(filenumber), '%03.f');
    filename = strcat(filepath, timepoint, filenamemid, groupnumber, filenameEnding);
end