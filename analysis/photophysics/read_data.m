function [heads] = read_data(myFolder, imtype)
%READ_DATA Reads the data in a folder
%   Creates a structure out of all the data contained in the given
%   folder. The inner organization of the structure and the convention on
%   naming the data can be extrapolated directly from the code below

% Version: 181210 - Use the new way of finding the maxima in MATLAB after
% a "FFT smoothing" instead of running a separate ImageJ script. Comment
% away the old way of reading the maxima from the .csv file. 

if exist(myFolder, 'dir') ~= 7
  Message = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(Message));
  return;
end

%% set the number of files
number_of_files = length(dir(fullfile(myFolder,'*_510+STED.tif')));
%check if the number of files is consistent
if number_of_files ~= length(dir(fullfile(myFolder,'*_STEDonly.tif')))
  Message = sprintf('Error: The number of files in the following folder is not consistent:\n%s', myFolder);
  uiwait(warndlg(Message));
  return;
end

%% define structure
%NOTE: it could be useful to consider preallocation at this moment
%NOTE 2: the mask and the x,y arrays are redundant, maybe in the end they
%have to be simplified. So far it is easier to have both though
heads = struct('STED_510',[],'STEDonly',[],'mask',[],'x',[],'y',[],'xalt',[],'yalt',[],'av_bkg_STED_510',[],'av_bkg_STEDonly',[],'npixelsblinkmask',[],'nbrightpx',[],'nblinkpx',[]);

%% read data
for k = 1:number_of_files
  %read all the files
  tifFilename_510_STED = sprintf('%.2d_510+STED.tif', k);
  imageData_510_STED   = imread(fullfile(myFolder,tifFilename_510_STED));
  tifFilename_STEDonly = sprintf('%.2d_STEDonly.tif', k);
  imageData_STEDonly   = imread(fullfile(myFolder,tifFilename_STEDonly));
%   textFilename = sprintf('%.2d_Maxima.csv', k);
%   textData     = csvread(fullfile(myFolder, textFilename),1,0);
  
  %put the files in the structure
  heads(k).STED_510 = imageData_510_STED;
  heads(k).STEDonly = imageData_STEDonly;
%   heads(k).x = textData(:,1);
%   heads(k).y = textData(:,2);
  
  %find the maxima through an alternative way using fourier transforms
  fftMaxima = find_fft_maxima(imageData_510_STED, imtype); 
  heads(k).x = fftMaxima(:,1);
  heads(k).y = fftMaxima(:,2);
  
  %update values of x and y for coordinate system of MATlab
%   heads(k).x = heads(k).x + ones(size(heads(k).x));
%   heads(k).y = heads(k).y + ones(size(heads(k).y));
  
  %create the mask
  heads(k).mask = create_mask(heads(k).x, heads(k).y, size(heads(k).STED_510));
%   heads(k).maskalt = create_mask(heads(k).xalt, heads(k).yalt, size(heads(k).STED_510));
  
  %initialize the average bkg
  heads(k).av_bkg_STED_510 = 0;
  heads(k).av_bkg_STEDonly = 0;
end

end

