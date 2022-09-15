%%% 
% ANALYSIS OF QD ENDOCYTOSIS DATA, GENERATE RESULTS SUCH AS SINGLE QD
% FRACTION, QD FRACTION INSIDE, SINGLE QD FRACTION INSIDE, DISTANCE TO
% NEAREST TUBULIN STRAND ETC. 
% 
% @JONATAN ALVELID
%%%

clear

% Add function folder to filepath, so that those functions can be read.
functionFolder = fileparts(which('findFunctionFolders.m'));
addpath(genpath(functionFolder));

folderPath = uigetdir('D:\Data analysis\QDs\QD - Endocytosis\Analyse all');
masterFolderPath = strcat(folderPath,'\');

vestype = input('Are the images early endosomes=1, late endosomes=2 or lysosomes=3? ');  % Determine which type of binarization of vesicle image to be done
pixelsize = input('What is the pixel size in nm? ')/1000;  % Pixel size in ?m

% Start with the raw images. Subtract QD images. Subtract STEDonly from
% vesicle images.

filenameqd = '_QD.tif';
filenameqdSo = '_QDSo.tif';
filenameves = '_Ves.tif';
filenamevesSo = '_VesSo.tif';
filenametub = '_Tub.tif';
filenametransfp = '-Transformation.txt';
timepoints = [0.25 0.5 1 3 6 12 18 24];
imgPerTimepoint = [0 0 0 0 0 0 0 0];

% Read all the files ending with QD.tif in the selected folder, 
files = dir(fullfile(folderPath, '*.tif'));
[~,ndx] = natsortfiles({files.name}); % indices of correct order
files = files(ndx); % sort structure using indices

for imgid = 1:5:length(files)
    [~, f] = fileparts(files(imgid).name);
    fileHour = str2double(f(1:2));
    if isnan(fileHour)
        fileHour = str2double(f(1));
    end
    if fileHour == 15 || fileHour == 30
        fileHour = fileHour/60;
    end
    imgPerTimepoint(timepoints == fileHour) = imgPerTimepoint(timepoints == fileHour) + 1;
end

fileNumbers = 1:sum(imgPerTimepoint);
timepointndx = [ones(imgPerTimepoint(1),1)*0.25; ones(imgPerTimepoint(2),1)*0.5; ones(imgPerTimepoint(3),1); ones(imgPerTimepoint(4),1)*3; ones(imgPerTimepoint(5),1)*6; ones(imgPerTimepoint(6),1)*12; ones(imgPerTimepoint(7),1)*18; ones(imgPerTimepoint(8),1)*24];
filenumberndx = [1:imgPerTimepoint(1) 1:imgPerTimepoint(2) 1:imgPerTimepoint(3) 1:imgPerTimepoint(4) 1:imgPerTimepoint(5) 1:imgPerTimepoint(6) 1:imgPerTimepoint(7) 1:imgPerTimepoint(8)]';

figure()

lastFileNumber = length(fileNumbers);
subplotfigs = ceil(sqrt(lastFileNumber));
qdFractionInsideVesicles = zeros(lastFileNumber,1);
qdFractionSingleQDsInside = zeros(lastFileNumber,1);
qdFractionSingleQDs = zeros(lastFileNumber,1);
    
for fileNum = fileNumbers
    filepathqd = strFilepath(fileNum, filenameqd, masterFolderPath, timepointndx, filenumberndx);
    filepathqdSo = strFilepath(fileNum, filenameqdSo, masterFolderPath, timepointndx, filenumberndx);
    filepathves = strFilepath(fileNum, filenameves, masterFolderPath, timepointndx, filenumberndx);
    filepathvesSo = strFilepath(fileNum, filenamevesSo, masterFolderPath, timepointndx, filenumberndx);
    filepathtub = strFilepath(fileNum, filenametub, masterFolderPath, timepointndx, filenumberndx);
    filepathtransfp = strFilepathTransf(fileNum, filenametransfp, masterFolderPath, timepointndx, filenumberndx, vestype);
    
    try
        % Read the images
        imgrawqd = imread(filepathqd);
        imgrawqdSo = imread(filepathqdSo);
        imgrawves = imread(filepathves);
        imgrawvesSo = imread(filepathvesSo);
        imgrawtub = imread(filepathtub);
        transfpoints = dlmread(filepathtransfp,'\t',5,0);
        imsize = size(imgrawqd);
        
        % Smooth the STED only image, in order to achieve a slightly better
        % subtraction process.
        % imgqdSo = imgaussfilt(imgrawqdSo, 1);
        imgqdSo = filter2(fspecial('average',3),imgrawqdSo);  % This equals ImageJ's "Smooth"
        % imgvesSo = imgaussfilt(imgrawvesSo, 1);
        imgvesSo = filter2(fspecial('average',3),imgrawvesSo);
        
        % Subtract the smoothed STEDonly images from the STED images.
        imgsubqd = imgrawqd - imgqdSo;
        imgsubqd( imgsubqd < 0 ) = 0;
        imgsubves = imgrawves - imgvesSo;
        imgsubves( imgsubves < 0 ) = 0;
        
%         figure()
%         imshow(imgrawves,[0 max(imgrawves(:))/4])
        
    catch err
        disp(strcat(num2str(fileNum),': No image with this number, or some other error.'));
        continue
    end
    
    %%% BINARY CELL IMAGE
    %%% Create binary cell image, and multiply the qd image with this.
    imgcell = imgsubves + imgrawtub;
    for n = 1:3
        imgcell = filter2(fspecial('average',10),imgcell);
    end
    imgcellbin = imbinarize(imgcell,graythresh(imgcell));
    imgcellbin = imfill(imgcellbin,'holes');
    ermat = [0 0 0 0 0 0 0;0 0 1 1 1 0 0;0 1 1 1 1 1 0;0 1 1 1 1 1 0;0 1 1 1 1 1 0;0 0 1 1 1 0 0;0 0 0 0 0 0 0];
    for n = 1:15
        imgcellbin = imerode(imgcellbin,ermat);
    end
    for n = 1:5
        imgcellbin = imdilate(imgcellbin,ermat);
    end
    
    imgsubqd = imgsubqd .* imgcellbin;

    %%% REPLACE PREVIOUS IMAGEJ SCRIPTS
    %%% Binarize vesicles images
    % Find the top x% of pixel, to get a threshold value for binarization.
    imgsort = sort(imgsubves(:),'descend');
    thresh_val = imgsort(ceil(length(imgsort)*0.08));
    % Smooth the vesimage
    imgsmoves = imgsubves;
    for n = 1:2
        imgsmoves = filter2(fspecial('average',5),imgsmoves);
    end
    % Binarize smoothed vesimage
    imgbinves0 = imbinarize(imgsmoves,thresh_val);
    % Do a series of erosion and dilation of the binary image
    ermat = [0 1 0;1 1 1;0 1 0];
    dilmat = [0 0 0 0 0 0 0;0 0 1 1 1 0 0;0 1 1 1 1 1 0;0 1 1 1 1 1 0;0 1 1 1 1 1 0;0 0 1 1 1 0 0;0 0 0 0 0 0 0];
    % Specify erosion/dilation sequence. Erosion = 1, Dilation = 0, Remove
    % small and large objects = 2
    erdilorder = [ones(1,1);2;zeros(1,1)];
    for n = 1:length(erdilorder)
        if erdilorder(n) == 1
            imgbinves0 = imerode(imgbinves0,ermat);
        elseif erdilorder(n) == 0
            imgbinves0 = imdilate(imgbinves0,dilmat);
        elseif erdilorder(n) == 2
            imgbinves0 = bwareafilt(imgbinves0, [10,10000]);
        end
    end
    % Multiply the created binary mask with the original image
    imgsmoves = imgsubves .* imgbinves0;
    % Smooth the vesimage
    for n = 1:1
        imgsmoves = filter2(fspecial('average',6),imgsmoves);
    end
    % Binarize smoothed vesimage
    imgbinves = imbinarize(imgsmoves, thresh_val);  % Does this really make sense? To use the same threshold again??
    % Specify erosion/dilation sequence. Erosion = 1, Dilation = 0, Remove
    % small objects = 2
    if vestype == 3
        erdilorder = [ones(1,1);2;ones(1,1)];
    else
        erdilorder = [ones(1,1);2;zeros(1,1);2;ones(3,1)];
    end
    for n = 1:length(erdilorder)
        if erdilorder(n) == 1
            imgbinves = imerode(imgbinves,ermat);
        elseif erdilorder(n) == 0
            imgbinves = imdilate(imgbinves,dilmat);
        elseif erdilorder(n) == 2
            if vestype == 3
                imgbinves = bwareafilt(imgbinves, [40,3000]);
            else
                imgbinves = bwareafilt(imgbinves, [40,1300]);
            end
        end
    end
    imgbinves = imfill(imgbinves, 'holes');
    subplot(subplotfigs, subplotfigs, fileNum);
    imshow(imgbinves, [])

    %%% Binarize the tubulin image (alternatively skeletonize it, but I
    %%% believe binarization worked best when done in ImageJ before). 
    % Find the top x% of pixel, to get a threshold value for binarization.
    imgsort = sort(imgrawtub(:),'descend');
    thresh_val1 = imgsort(ceil(length(imgsort)*0.6));
    thresh_val2 = imgsort(ceil(length(imgsort)*0.5));
    % Delete background values
    imgrawtub(imgrawtub < 5) = 0;
    % Smooth the tubulin image
    imgsmotub = imgrawtub;
    for n = 1:1
        imgsmotub = filter2(fspecial('average',5),imgsmotub);
    end
    % Binarize smoothed tubulin image
    imgbintubimd = imbinarize(imgsmotub,thresh_val1);
    % Do a series of erosion and dilation of the binary image
    ermat = [0 1 0;1 1 1;0 1 0]; 
    % Specify erosion/dilation sequence. Erosion = 1, Dilation = 0
    erdilorder = [ones(0,1);zeros(0,1)];
    for n = 1:length(erdilorder)
        if erdilorder(n) == 1
            imgbintubimd = imerode(imgbintubimd,ermat);
        elseif erdilorder(n) == 0
            imgbintubimd = imdilate(imgbintubimd,ermat);
        end
    end
    % Multiply with original image
    imgbintub = imgbintubimd .* imgrawtub;
    % Smooth 1x
    imgbintub = filter2(fspecial('average',2),imgbintub);
    % Make binary
    imgbintub = imbinarize(imgbintub, thresh_val2);
    % Erode, Dilate
    % Specify erosion/dilation sequence. Erosion = 1, Dilation = 0
    erdilorder = [ones(1,1); zeros(0,1)];
    for n = 1:length(erdilorder)
        if erdilorder(n) == 1
            imgbintub = imerode(imgbintub,ermat);
        elseif erdilorder(n) == 0
            imgbintub = imdilate(imgbintub,ermat);
        end
    end
%     figure()
%     imshow(imgbintub,[])
    
    %%% Find maxima in subtracted QD image
    % Smooth and pre-process the qdimage
    imgsmoqdpeak = imgsubqd;
    imgsubqdgrad = imgsubqd;
    imgsubqdgrad = filter2(fspecial('average',8),imgsubqdgrad);
    [imgGmag, ~] = imgradient(imgsubqdgrad,'prewitt');
    imgsmoqdpeak = filter2(fspecial('average',6),imgsmoqdpeak);
    imgsubqd = imgsmoqdpeak - filter2(fspecial('average',15),imgsmoqdpeak) - filter2(fspecial('average',100),imgGmag);
    imgsubqd = filter2(fspecial('average',6),imgsubqd);
    
    % Find all maxima with FastPeakFind function (from MathWorks File
    % exchange), and put them in separate x- and y-vectors.
    fpff = 3;  % VERY SENSITIVE TO THIS FACTOR, POSSIBLY TOO SENSITIVE FROM IMAGE TO IMAGE.
    % fpff = 2.5 was how it was for 181206 analysis.
    
    imgsubqd(imgsubqd<0) = 0;
    imgsort = sort(imgsubqd(:),'descend');
    thresh_val = imgsort(ceil(length(imgsort)*0.2));

    [qdpeakcoord, qdpeakbin] = FastPeakFind(imgsubqd, thresh_val * fpff);
    qdpeakxcoord = zeros(length(qdpeakcoord)/2,1);
    qdpeakycoord = zeros(length(qdpeakcoord)/2,1);
    for n = 1:length(qdpeakcoord)/2
        qdpeakxcoord(n) = qdpeakcoord(2*n - 1);
        qdpeakycoord(n) = qdpeakcoord(2*n);
    end

    % Delete those maxima that are too close to the border, to fully see the
    % circle to check if it is a single QD for example. Also to avoid the noise
    % that I have close to the border due to non-perfect bleaching close to the
    % top etc.
    pixeldist = 16;
    qdpeakxcoordtemp = qdpeakxcoord;
    qdpeakycoordtemp = qdpeakycoord;
    for n = 1:length(qdpeakxcoordtemp)
        if qdpeakycoordtemp(n) - pixeldist < 0 || qdpeakycoordtemp(n) + pixeldist > length(imgsubqd) || qdpeakxcoordtemp(n) - pixeldist < 0 || qdpeakxcoordtemp(n) + pixeldist > length(imgsubqd)
            qdpeakxcoord(n) = NaN;
            qdpeakycoord(n) = NaN;
        end
    end
    qdpeakxcoord(isnan(qdpeakxcoord)) = [];
    qdpeakycoord(isnan(qdpeakycoord)) = [];
    
    % For every maxima, sum a rectangle around the maxima and delete those
    % maxima with a sum smaller than that of a rectangle filled with
    % average pixel values times some factor. Also delete those that are
    % too close to the border to take this rectangle.
    rectsize = 7;
    findQDsavgfactor = 1.1;
    [bkg_av, bkg_std, ~] = bkg(imgsubqd,qdpeakxcoord,qdpeakycoord,0.800,pixelsize);
    sumthresh = mean(imgsubqd(:)) * rectsize * rectsize * findQDsavgfactor;
    qdpeakxcoordtemp = qdpeakxcoord;
    qdpeakycoordtemp = qdpeakycoord;
    for n = 1:length(qdpeakxcoordtemp)
        sumtemp = sum(reshape(imgsubqd(qdpeakycoordtemp(n)-(rectsize-1)/2:qdpeakycoordtemp(n)+(rectsize-1)/2,qdpeakxcoordtemp(n)-(rectsize-1)/2:qdpeakxcoordtemp(n)+(rectsize-1)/2),[],1));
        if sumtemp < sumthresh
            qdpeakxcoord(n) = NaN;
            qdpeakycoord(n) = NaN;
        end
    end
    qdpeakxcoord(isnan(qdpeakxcoord)) = [];
    qdpeakycoord(isnan(qdpeakycoord)) = [];
    
    % For every maxima, check the distance to all other maximas, and
    % delete those that are too close to the first maxima
    for i = 1:(length(qdpeakxcoord) - 1)
        for j = (i + 1):length(qdpeakxcoord)
            % Check if the distance between the two peak coordinates is
            % less than 100 nm, i.e. if it is clearly a case of multiple
            % peaks being detected for the same big clutser. In that case,
            % remove the second maxima.
            p2pdist = sqrt((qdpeakxcoord(i) - qdpeakxcoord(j))^2 + (qdpeakycoord(i) - qdpeakycoord(j))^2)*pixelsize;
            if p2pdist < 0.1
                qdpeakycoord(j) = NaN;
                qdpeakxcoord(j) = NaN;
            end 
        end
    end
    qdpeakxcoord(isnan(qdpeakxcoord)) = [];
    qdpeakycoord(isnan(qdpeakycoord)) = [];
    
    % Make distance mapping matrices, for tubulin and the
    % endosomes/lysosomes, convert to um.
    imgrawvesbin = imgbinves;
    imgrawtubbin = imgbintub;
    imgrawqdso = imgrawqdSo;
    xpos = qdpeakxcoord;
    ypos = qdpeakycoord;
    distimgmatvesbin = bwdist(imgrawvesbin) * pixelsize;
    distimgmattubskel = bwdist(imgrawtubbin) * pixelsize;

    noQDs = length(xpos);
    allData = zeros(noQDs,6);
    
    % Calculate the affine transformation matrix from the input transformed
    % points.
    xtrans = transfpoints(1:3,:);
    x_primetrans = transfpoints(4:6,:);
    [A, flag] = getaffinematrix(xtrans,x_primetrans);
    if flag == 1
        disp('The shift for this image was not calculated properly, euclidean D > 30.')
    end
    qdpoints = [xpos ypos ones(noQDs,1)];
    [sizrow, ~] = size(qdpoints);
    for i = 1:sizrow
        newpos = A * qdpoints(i,1:3)';
        if newpos(1) < 0
            newpos(1) = 0;
        elseif newpos(1) > imsize(1) 
            newpos(1) = imsize(1);
        end
        if newpos(2) < 0
            newpos(2) = 0;
        elseif newpos(2) > imsize(1)
            newpos(2) = imsize(1);
        end
        qdpointscorr(i,1:3) = newpos;
    end
    xposcorr = qdpointscorr(1:end,1);
    yposcorr = qdpointscorr(1:end,2);
    
    for i = 1:noQDs
        distvesbin = distanceMapCheck(xposcorr(i), yposcorr(i), distimgmatvesbin);
        disttubskel = distanceMapCheck(xposcorr(i), yposcorr(i), distimgmattubskel);
        allData(i,1) = xpos(i)*pixelsize;
        allData(i,2) = ypos(i)*pixelsize;
        allData(i,3) = distvesbin;
        allData(i,4) = disttubskel;
    end

    
    % Add a boolean variable telling if the QD is a single QD or a cluster,
    % by looking at the center hole of the donut in the STEDonly image.
    allData(:,5) = singleQDCheck(imgrawqdso,xpos,ypos,pixelsize);
    
    % Add a boolean variable telling if the QD is located inside a vesicle.
    % Define inside a vesicle as less than 300 nm from a vesicle (due to
    % drift, can adapt this later if I find a robust way of registering
    % the images. 
    allData(:,6) = (allData(:,3) <= 0.1);
    
    filesavenameqddata = strFilepath(fileNum, '_QDData.txt', masterFolderPath, timepointndx, filenumberndx);
    dlmwrite(filesavenameqddata, allData, 'delimiter', '\t', 'precision', 6);
    disp(filesavenameqddata)
    
end
