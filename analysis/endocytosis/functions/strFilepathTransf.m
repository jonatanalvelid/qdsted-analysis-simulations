%%% Returns a proper filename from the input values
function [filename2] = strFilepathTransf(filenumber, filenameEnding, filepath, timepointindex, filenumberindex, vestype)
    if vestype == 1
        ves = 'EE';
    elseif vestype == 2
        ves = 'LE';
    elseif vestype == 3
        ves = 'Lys';
    end
    timepoint = timepointindex(filenumber);
    if timepoint < 1
        timepoint = timepoint*60;
        filenamemid = 'min-';
    else
        filenamemid = 'h-';
    end
    timepoint = num2str(timepoint);
    groupnumber = num2str(filenumberindex(filenumber), '%03.f');
    filename2 = strcat(filepath, timepoint, filenamemid, ves, '-', groupnumber, filenameEnding);
end