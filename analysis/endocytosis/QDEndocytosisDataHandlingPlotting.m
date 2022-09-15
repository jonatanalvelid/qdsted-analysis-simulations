%%% 
% DO ALL DATA HANDLING AND PARAMETER EXTRACTION FROM THE DATA GENERATED IN
% THE ANALYSIS SCRIPT. ALSO PLOT THESE RESULTS. 
% 
% @JONATAN ALVELID
%%%

%%
%clear

% Add function folder to filepath, so that those functions can be read.
functionFolder = fileparts(which('findFunctionFolders.m'));
addpath(genpath(functionFolder));

folderPath = uigetdir('D:\Data analysis\QDs\QD - Endocytosis');
masterFolderPath = strcat(folderPath,'\');

% lastFileNumber = input('How many images do you have in total? ');
% noimgpertp = input('How many images do you have per timepoint? ');
vestype = input('Are the images early endosomes=1, late endosomes=2 or lysosomes=3? ');

filenameqddata = '_QDData.txt';
timepoints = [15/60 30/60 1 3 6 12 18 24];
imgPerTimepoint = [0 0 0 0 0 0 0 0];
% allTubDistIns = 0;
% allTubDistOut = 0;

% Read all the files ending with '.tif' in the selected folder, 
files = dir(fullfile(folderPath, '*.tif'));
[~,ndx] = natsortfiles({files.name}); % indices of correct order
files = files(ndx); % sort structure using indices

for imgid = 1:5:length(files)
    [~, f] = fileparts(files(imgid).name);
    fileHour = str2double(f(1:2));
    if isnan(fileHour)
        fileHour = str2double(f(1));
    elseif fileHour == 15 || fileHour == 30
        fileHour = fileHour / 60;
    end
    imgPerTimepoint(timepoints == fileHour) = imgPerTimepoint(timepoints == fileHour) + 1;
end

fileNumbers = 1:sum(imgPerTimepoint);
timepointndx = [ones(imgPerTimepoint(1),1)*15/60; ones(imgPerTimepoint(2),1)*30/60; ones(imgPerTimepoint(3),1); ones(imgPerTimepoint(4),1)*3; ones(imgPerTimepoint(5),1)*6; ones(imgPerTimepoint(6),1)*12; ones(imgPerTimepoint(7),1)*18; ones(imgPerTimepoint(8),1)*24];
filenumberndx = [1:imgPerTimepoint(1) 1:imgPerTimepoint(2) 1:imgPerTimepoint(3) 1:imgPerTimepoint(4) 1:imgPerTimepoint(5) 1:imgPerTimepoint(6) 1:imgPerTimepoint(7) 1:imgPerTimepoint(8)]';


%% 
%%% QD DATA HANDLING

lastFileNumber = length(fileNumbers);
qdFractionInsideVesicles = nan(lastFileNumber,1);
qdFractionSingleQDs = nan(lastFileNumber,1);
qdFractionSingleQDsInside = nan(lastFileNumber,1);
qdFractionClusterQDs = nan(lastFileNumber,1);
qdFractionClusterQDsInside = nan(lastFileNumber,1);
noQDsCells = nan(lastFileNumber,1);
dataqdall = nan(1000,6,lastFileNumber);
allTubDistIns = nan(1000,lastFileNumber);
allTubDistOut = nan(1000,lastFileNumber);

for fileNum = fileNumbers
    filepathqddata = strFilepath(fileNum, filenameqddata, masterFolderPath, timepointndx, filenumberndx);
    disp(filepathqddata)
    
    try
        % Read the QD data
        dataqd = dlmread(filepathqddata);
        noQDs = length(dataqd);
        dataqdall(1:noQDs,1:6,fileNum) = dataqd;
        
        % Calculate the fraction of QDs inside vesicles, the fraction of
        % QDs that are single as well as the fraction of QDs that are
        % inside vesicles that also are single QDs.
        noQDsCells(fileNum) = noQDs;
        noSingleQDsCells(fileNum) = sum(dataqd(:,5));
        qdFractionInsideVesicles(fileNum) = sum(dataqd(:,6))/noQDs;
        qdFractionSingleQDs(fileNum) = sum(dataqd(:,5))/noQDs;
        qdFractionSingleQDsInside(fileNum) = sum(dataqd(:,6) & dataqd(:,5))/sum(dataqd(:,6));
        qdFractionClusterQDs(fileNum) = sum(~dataqd(:,5))/noQDs;
        qdFractionClusterQDsInside(fileNum) = sum(dataqd(:,6) & ~dataqd(:,5))/sum(dataqd(:,6));
        
        % Add all tubulin distances as well as vesicles distances to a
        % vector.
%         allVesDist = [allVesDist; dataqd(:,3)];

        allTubDistIns(1:length(dataqd(dataqd(:,6)==1,4)),fileNum) = dataqd(dataqd(:,6)==1,4);
        allTubDistOut(1:length(dataqd(dataqd(:,6)==0,4)),fileNum) = dataqd(dataqd(:,6)==0,4);
        
    catch err
        disp(strcat(num2str(fileNum),': No image with this number, or some other error.'));
    end 
end

% disp(qdFractionInsideVesicles);
% disp(qdFractionSingleQDsInside);
% disp(qdFractionSingleQDs);
figure(1)
hold on
scatter(qdFractionSingleQDs,qdFractionSingleQDsInside)

% disp('Fraction of single QDs inside vesicles - mean')
% mean(qdFractionSingleQDsInside(~isnan(qdFractionSingleQDsInside)))
% disp('Fraction of single QDs inside vesicles - std')
% std(qdFractionSingleQDsInside(~isnan(qdFractionSingleQDsInside)))

figure(12)
hold on
scatter(timepointndx, qdFractionSingleQDsInside)

sz = timepointndx;
for i = 1:length(timepoints)
    tempvar = qdFractionSingleQDsInside(timepointndx==timepoints(i));
    tempvar2 = qdFractionSingleQDs(timepointndx==timepoints(i));
    meanSingleQDsInsideTimepoints(i) = mean(tempvar(~isnan(tempvar)));
    stdSingleQDsInsideTimepoints(i) = std(tempvar(~isnan(tempvar)));
    meanSingleQDsInsideVarTimepoints(i) = mean(tempvar(~isnan(tempvar))./tempvar2(~isnan(tempvar)));
    stdSingleQDsInsideVarTimepoints(i) = std(tempvar(~isnan(tempvar))./tempvar2(~isnan(tempvar)));
    sz(timepointndx==timepoints(i)) = i;
end
sz2 = noSingleQDsCells;

figure(9)
hold on
errorbar(timepoints,meanSingleQDsInsideTimepoints,stdSingleQDsInsideTimepoints)
errorbar(timepoints,meanSingleQDsInsideVarTimepoints,stdSingleQDsInsideVarTimepoints,'--')

figure(3)
hold on
scatter(qdFractionSingleQDs,qdFractionSingleQDsInside,3*2.^sz,'filled')
    
figure(13)
hold on
scatter(timepointndx,qdFractionSingleQDsInside,qdFractionSingleQDs*300,'filled')
    
figure(6)
hold on
scatter(qdFractionClusterQDs,qdFractionClusterQDsInside)

figure(2)
hold on
histogram(allTubDistIns, [0:0.033:0.75], 'Normalization', 'pdf')
histogram(allTubDistOut, [0:0.033:0.75], 'Normalization', 'pdf')
xlabel('Tubulin distance T [?m]');
ylabel('Frequency [arb.u.]');

mean(allTubDistIns(~isnan(allTubDistIns) & allTubDistIns < 2))
std(allTubDistIns(~isnan(allTubDistIns) & allTubDistIns < 2))
median(allTubDistIns(~isnan(allTubDistIns)))
size(allTubDistIns(~isnan(allTubDistIns) & allTubDistIns < 2))

mean(allTubDistOut(~isnan(allTubDistOut) & allTubDistOut < 2))
std(allTubDistOut(~isnan(allTubDistOut) & allTubDistOut < 2))
median(allTubDistOut(~isnan(allTubDistOut)))
size(allTubDistOut(~isnan(allTubDistOut) & allTubDistOut < 2))

% allallTubDistOut = [allallTubDistOut;allTubDistOut(~isnan(allTubDistOut) & allTubDistOut < 2)];
% median(allallTubDistOut)

if vestype == 1
    qdFSQEE = qdFractionSingleQDs;
    qdFSQIEE = qdFractionSingleQDsInside;
    qdFCQEE = qdFractionClusterQDs;
    qdFCQIEE = qdFractionClusterQDsInside;
    qdFIEE = qdFractionInsideVesicles;
    varEE = qdFSQIEE./qdFSQEE;
    varCEE = qdFCQIEE./qdFCQEE;
    allTubDistInsEE = allTubDistIns;
    allTubDistOutEE = allTubDistOut;
    fractionInsideAgeEE = [];
    stdFractionInsideAgeEE = [];
    qdFIEE2 = [];
    tubDistInsmeanEE = [];
    tubDistOutmeanEE = [];
    for i = 1:length(timepoints)
        fractionInsideAgeEE = [fractionInsideAgeEE mean(qdFIEE(timepointndx == timepoints(i)))];
        stdFractionInsideAgeEE = [stdFractionInsideAgeEE std(qdFIEE(timepointndx == timepoints(i)))];
        qdFIEE2 = [qdFIEE2; qdFIEE(timepointndx == timepoints(i))];
    end
%     fractionInsideAgeEE = [mean(qdFIEE(timepointndx == timepoints(1))) mean(qdFIEE(timepointndx == timepoints(2))) mean(qdFIEE(timepointndx == timepoints(3))) mean(qdFIEE(timepointndx == timepoints(4))) mean(qdFIEE(timepointndx == timepoints(5))) mean(qdFIEE(timepointndx == timepoints(6))) mean(qdFIEE(timepointndx == timepoints(7))) mean(qdFIEE(timepointndx == timepoints(8)))]; 
%     stdFractionInsideAgeEE = [std(qdFIEE(timepointndx == timepoints(1))) std(qdFIEE(timepointndx == timepoints(2))) std(qdFIEE(timepointndx == timepoints(3))) std(qdFIEE(timepointndx == timepoints(4))) std(qdFIEE(timepointndx == timepoints(5))) std(qdFIEE(timepointndx == timepoints(6))) std(qdFIEE(timepointndx == timepoints(7))) std(qdFIEE(timepointndx == timepoints(8)))];
    figure(4)
    hold on
    scatter(timepointndx, qdFIEE)
    
    for i = fileNumbers
        tubDistInsmeanEE(i) = mean(allTubDistInsEE(~isnan(allTubDistInsEE(:,i)) & allTubDistInsEE(:,i) < 1,i));
        tubDistOutmeanEE(i) = mean(allTubDistOutEE(~isnan(allTubDistOutEE(:,i)) & allTubDistOutEE(:,i) < 1,i));
    end
    for i = 1:length(timepoints)
        tubDistInsmeanmeanEE(i) = mean(tubDistInsmeanEE(timepointndx==timepoints(i)));
        tubDistOutmeanmeanEE(i) = mean(tubDistOutmeanEE(timepointndx==timepoints(i)));
    end
    
    figure(10)
    hold on
    scatter(timepoints, tubDistInsmeanmeanEE)
    figure(11)
    hold on
    scatter(timepoints, tubDistOutmeanmeanEE)
    
    figure(7)
    hold on
    boxplot(qdFIEE)
elseif vestype == 2
    qdFSQLE = qdFractionSingleQDs;
    qdFSQILE = qdFractionSingleQDsInside;
    qdFCQLE = qdFractionClusterQDs;
    qdFCQILE = qdFractionClusterQDsInside;
    qdFILE = qdFractionInsideVesicles;
    varLE = qdFSQILE./qdFSQLE;
    varCLE = qdFCQILE./qdFCQLE;
    allTubDistInsLE = allTubDistIns;
    allTubDistOutLE = allTubDistOut;
    fractionInsideAgeLE = [];
    stdFractionInsideAgeLE = [];
    qdFILE2 = [];
    tubDistInsmeanLE = [];
    tubDistOutmeanLE = [];
    for i = 1:length(timepoints)
        fractionInsideAgeLE = [fractionInsideAgeLE mean(qdFILE(timepointndx == timepoints(i)))];
        stdFractionInsideAgeLE = [stdFractionInsideAgeLE std(qdFILE(timepointndx == timepoints(i)))];
        qdFILE2 = [qdFILE2; qdFILE(timepointndx == timepoints(i))];
    end
%     fractionInsideAgeLE = [mean(qdFILE(timepointndx == timepoints(1))) mean(qdFILE(timepointndx == timepoints(2))) mean(qdFILE(timepointndx == timepoints(3))) mean(qdFILE(timepointndx == timepoints(4))) mean(qdFILE(timepointndx == timepoints(5))) mean(qdFILE(timepointndx == timepoints(6))) mean(qdFILE(timepointndx == timepoints(7))) mean(qdFILE(timepointndx == timepoints(8)))]; 
%     stdFractionInsideAgeLE = [std(qdFILE(timepointndx == timepoints(1))) std(qdFILE(timepointndx == timepoints(2))) std(qdFILE(timepointndx == timepoints(3))) std(qdFILE(timepointndx == timepoints(4))) std(qdFILE(timepointndx == timepoints(5))) std(qdFILE(timepointndx == timepoints(6))) std(qdFILE(timepointndx == timepoints(7))) std(qdFILE(timepointndx == timepoints(8)))];
%     bar(timepoints, fractionInsideAgeLE)
    figure(4)
    hold on
    scatter(timepointndx+0.3, qdFILE)
    
    for i = fileNumbers
        tubDistInsmeanLE(i) = mean(allTubDistInsLE(~isnan(allTubDistInsLE(:,i)) & allTubDistInsLE(:,i) < 1,i));
        tubDistOutmeanLE(i) = mean(allTubDistOutLE(~isnan(allTubDistOutLE(:,i)) & allTubDistOutLE(:,i) < 1,i));
    end
    for i = 1:length(timepoints)
        tubDistInsmeanmeanLE(i) = mean(tubDistInsmeanLE(timepointndx==timepoints(i)));
        tubDistOutmeanmeanLE(i) = mean(tubDistOutmeanLE(timepointndx==timepoints(i)));
    end
    
    figure(10)
    hold on
    scatter(timepoints, tubDistInsmeanmeanLE)
    figure(11)
    hold on
    scatter(timepoints, tubDistOutmeanmeanLE)
    
    figure(7)
    hold on
    scatter(timepointndx+0.3, qdFILE)
elseif vestype == 3
    qdFSQLys = qdFractionSingleQDs;
    qdFSQILys = qdFractionSingleQDsInside;
    qdFCQLys = qdFractionClusterQDs;
    qdFCQILys = qdFractionClusterQDsInside;
    qdFILys = qdFractionInsideVesicles;
    varLys = qdFSQILys./qdFSQLys;
    varCLys = qdFCQILys./qdFCQLys;
    allTubDistInsLys = allTubDistIns;
    allTubDistOutLys = allTubDistOut;
    fractionInsideAgeLys = [];
    stdFractionInsideAgeLys = [];
    qdFILys2 = [];
    tubDistInsmeanLys = [];
    tubDistOutmeanLys = [];
    for i = 1:length(timepoints)
        fractionInsideAgeLys = [fractionInsideAgeLys mean(qdFILys(timepointndx == timepoints(i)))];
        stdFractionInsideAgeLys = [stdFractionInsideAgeLys std(qdFILys(timepointndx == timepoints(i)))];
        qdFILys2 = [qdFILys2; qdFILys(timepointndx == timepoints(i))];
    end
%     fractionInsideAgeLys = [mean(qdFILys(timepointndx == timepoints(1))) mean(qdFILys(timepointndx == timepoints(2))) mean(qdFILys(timepointndx == timepoints(3))) mean(qdFILys(timepointndx == timepoints(4))) mean(qdFILys(timepointndx == timepoints(5))) mean(qdFILys(timepointndx == timepoints(6))) mean(qdFILys(timepointndx == timepoints(7))) mean(qdFILys(timepointndx == timepoints(8)))]; 
%     stdFractionInsideAgeLys = [std(qdFILys(timepointndx == timepoints(1))) std(qdFILys(timepointndx == timepoints(2))) std(qdFILys(timepointndx == timepoints(3))) std(qdFILys(timepointndx == timepoints(4))) std(qdFILys(timepointndx == timepoints(5))) std(qdFILys(timepointndx == timepoints(6))) std(qdFILys(timepointndx == timepoints(7))) std(qdFILys(timepointndx == timepoints(8)))]; 
%     bar(timepoints, fractionInsideAgeLys)
    figure(4)
    hold on
    scatter(timepointndx+0.6, qdFILys)
    
    for i = fileNumbers
        tubDistInsmeanLys(i) = mean(allTubDistInsLys(~isnan(allTubDistInsLys(:,i)) & allTubDistInsLys(:,i) < 1,i));
        tubDistOutmeanLys(i) = mean(allTubDistOutLys(~isnan(allTubDistOutLys(:,i)) & allTubDistOutLys(:,i) < 1,i));
    end
    for i = 1:length(timepoints)
        tubDistInsmeanmeanLys(i) = mean(tubDistInsmeanLys(timepointndx==timepoints(i)));
        tubDistOutmeanmeanLys(i) = mean(tubDistOutmeanLys(timepointndx==timepoints(i)));
    end
    
    figure(10)
    hold on
    scatter(timepoints, tubDistInsmeanmeanLys)
    figure(11)
    hold on
    scatter(timepoints, tubDistOutmeanmeanLys)
    
    figure(7)
    hold on
    g = [];
    for i = length(timepoints)
        g = [g;ones(length(qdFILys2)*(i-1),i)];
    end
    boxplot(qdFILys2, g)
end
figure(4)
xlabel('Incubation time [h]');
ylabel('QD fraction inside vesicles [arb.u.]');
if exist('fractionInsideAgeEE','var') && exist('fractionInsideAgeLE','var') && exist('fractionInsideAgeLys','var')
    figure(5)
    fracall = zeros(length(timepoints),3);
    fracall(:,1) = fractionInsideAgeEE';
    fracall(:,2) = fractionInsideAgeLE';
    fracall(:,3) = fractionInsideAgeLys';
    bar(timepoints,fracall)
    xlabel('Incubation time [h]');
    ylabel('QD fraction inside vesicles [arb.u.]');
end