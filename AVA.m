%INITIALIZATION------------------------------------------------------------
close all   % close figures
clc         % clear command window
clear       % clear all variables
workspace   % ensure workspace is visible
fontSize = 20;

% affine transformation coefficients to map points in range [w,x] to [y,z]
% w was determined experimentally
w = 0.0025; % 0.002446203730662
x = 10^-5;  % 0.0009655742695749367
y = 1;
z = 5;

cropSelect = [1900 1500 300 245]; % 1900 1500 300 245

myFolder = uigetdir('C:\');                 % source folder
filePattern = fullfile(myFolder, '*.jpg');  % pattern for image files
jpegFiles = dir(filePattern);               % retrieve info on image files
numFiles = numel(jpegFiles);                % number of image files
% read and organize images
images = cell(1,numFiles);                  % image cell array
crops = cell(1,numFiles);                   % cropped image cell array
for i = 1:numFiles
  baseFileName = jpegFiles(i).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Reading %s\n', baseFileName)
  images{i} = imread(fullFileName);
  crops{i} = imcrop(images{i},cropSelect);
end
fprintf('\nFinished reading images.\n\n')

%IMAGE ANALYSIS------------------------------------------------------------

B = cell(1,numFiles);
b = cell(1,numFiles);
db = cell(1,numFiles);
adb = zeros(1, numFiles);
rating = zeros(1,numFiles);
for i = 1:numFiles
    C = rgb2hsv(crops{i});          % format-converted cropped image
    B{i} = C(:,:,3);                  % brightness matrix of image
%     C = rgb2lab(crops{i});
%     B{i} = C(:,:,1);
%     C = rgb2gray(crops{i});
%     B{i} = C(:,:);

    b{i} = mean(B{i},2);    % average brightness of each row of pixels
    db{i} = diff(b{i});     % vertical change in brightness
    % calculate rating
    adb(i) = mean(smooth_db{i});      % average vertical change in brightness
    rating(i) = (adb(i)-w)*(z-y)/(x-w)+y;
    fprintf(1, 'Rating for %s:\t%0.2f\t(%d)\n', jpegFiles(i).name, rating(i), round(rating(i)))
end

%IMAGE DISPLAY-------------------------------------------------------------

figure(1)  % images
for i = 1:numFiles
    subplot(3,numFiles,i), imshow(images{i}); title(strcat({'Sample '},num2str(i)))
    subplot(3,numFiles,i+numFiles), imshow(crops{i}); title(strcat({'Crop '},num2str(i)))
    subplot(3,numFiles,i+2*numFiles), imshow(B{i}); title(strcat({'Brightness Matrix '},num2str(i)))
end

figure(2)  % plots
for i = 1:numFiles
    subplot(3,numFiles,i), imshow(B{i}); title(strcat({'Brightness Matrix '},num2str(i)))
    subplot(3,numFiles,i+numFiles), plot(1:size(b{i}),b{i}); xlim([-inf cropSelect(4)]); ylim([min(b{i})-0.1*range(b{i}) max(b{i})+0.1*range(b{i})]); title(strcat({'Horiz Slice Avgs '},num2str(i)))
    subplot(3,numFiles,i+2*numFiles), plot(1:size(db{i}),db{i}); xlim([-inf cropSelect(4)]); ylim([min(db{i})-0.1*range(db{i}) max(db{i})+0.1*range(db{i})]); title(strcat({'d(Horiz Slice Avgs) '},num2str(i)))
end

function r = range(A)
    r = max(A) - min(A);
end