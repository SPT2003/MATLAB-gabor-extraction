clc; close all; clear all
%this section obtains the data from the image files. 
folderPath = "C:\Users\erict\Downloads\cps20100428.ppm";

% Get a list of all image files in the folder
imageFiles = dir(fullfile(folderPath, '*.ppm'));

%maximum number of images is 308, but matlab can't store that much. 
%num is the number of big images
num = 150;
%imS is the size of the sample images. 
imS = 250;
%size of the database to store images and spikecount
dataM = zeros(num*(11*17),imS^2+1);

% Loop through each image file
for i = 1:num
    % for i = 1:length(imageFiles)
    % Construct the full file path
    filePath = fullfile(folderPath, imageFiles(i).name);

    % Read the image
    currentImage = imread(filePath);

    % Perform  operations on the current image

    % Convert to grayscale
    grayImage = rgb2gray(currentImage);

    % Normalize the data to the full uint16 range
    normalizedImage = double((mat2gray(grayImage)));
    % Add processing and data encoding. 
   g=gb(imS,imS/1.5, 40, imS/5);

    for j = 0:10
        for k = 0:16
            smallImage = mat2gray(normalizedImage((j*250+1):(j*250)+250,(k*250+1):(k*250)+250));
            outMag = smallImage.*g;
            result = sum(outMag,"all");
            %half wave rectification. 
            if result < 0 
                result = 0;
            end
            imageData = smallImage(:)';

            %using poisson rng to generate a spike count. 
            spikeCout = poissrnd(result);
            %writing stuff to the data matrix. 
            dLine = [imageData,spikeCout];
            dataM((j+1)*(k+1),:) = dLine;
            %fprintf("%d\n",spikeCout);
        end
    end
    
    

    
    %write image to a data file. 
    fprintf('Image %d done\n', i);

end

%%
%run this section to find the averaged image and the gabor that was used. 
%summed value of the spikes
weight = sum(dataM(:,imS^2+1));

%gabor estimate matrix. 
gE = zeros(1,imS^2);

%summing the images with the weighting factor
for i = 1:num
    gE = gE + dataM(i,imS^2+1)/weight*dataM(i,1:imS^2);
end


%reshaping the image, 
gE = reshape(gE,imS,imS);
gE = mat2gray(gE);


% Specify the desired magnification factor
magnificationFactor = 4;  % Adjust this value as needed

% Resize the image
resizedImage = imresize(gE, magnificationFactor, 'nearest');

% Display the resized image
figure
imshow(resizedImage, 'InitialMagnification', 'fit',"Colormap",gray);
figure
imshow(mat2gray(g), 'InitialMagnification', 'fit',"Colormap",gray);
%%
%run this section to optimise the gabor. 
% Define the objective function
objectiveFunction = @(params) abs(1-corr2(gE, gb(imS, params(1), params(2), params(3))));

% Initial guess for Gabor parameters
initialGuess = [10,10, 2];


% Run the optimization and visualise the process. 
options = optimset('PlotFcns',@optimplotfval);
optimizedParameters = fminsearch(objectiveFunction, initialGuess, options);

% Display the optimized parameters
disp('Optimized Parameters:');
disp(['Lambda: ', num2str(optimizedParameters(1))]);
disp(['Theta: ', num2str(optimizedParameters(2))]);
disp(['Sigma: ', num2str(optimizedParameters(3))]);

% Display the optimized Gabor filter
optimizedGabor = gb(imS, optimizedParameters(1), optimizedParameters(2), optimizedParameters(3));
figure;
imshow(mat2gray(optimizedGabor), 'InitialMagnification', 'fit', 'Colormap', gray);
title('Optimized Gabor Filter');




