clc; close all; clear all

%natural images but with a different weighting system.

%code goes through image files first to find a collective "weighting sum",
%then loops through it again to add them by weight to the Gabor estimate gE
%variable. 


%this section obtains the data from the image files. 
folderPath = "C:\Users\erict\Downloads\cps20100428.ppm";

% Get a list of all image files in the folder
imageFiles = dir(fullfile(folderPath, '*.ppm'));

%maximum number of images is 308, but matlab can't store that much. 
%num is the number of big images
num = 5;
%imS is the size of the sample images. 
imS = 36;

dataM = zeros(num*(79*119),imS^2+1);

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
   g=gb(imS,imS/1.5, 10, imS/5);

    for j = 0:78
        for k = 0:118
            smallImage = mat2gray(normalizedImage((j*36+1):(j*36)+36,(k*36+1):(k*36)+36));
            
            % Specify the desired magnification factor
            % magnificationFactor = 4;  % Adjust this value as needed

            % Resize the image
            % resizedImage = imresize(smallImage, magnificationFactor, 'nearest');
            %imshow(resizedImage,'InitialMagnification','fit');

            %smallImage = imresize(smallImage,[imS,imS]);
            outMag = smallImage.*g;
            %outMag = imfilter(smallImage,g);
           
            result = 100+ sum(outMag,"all");
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
        end
    end
    
    

    
    %write image to a data file. 
    fprintf('Image %d done for part 1\n', i);

end
%%



%making the dataset. X is all the image data Y is all the spikeCounts
X = dataM(:,1:imS^2);
Y = dataM(:,imS^2+1);





nonLinearModel = @(beta,X) (100+sum(X.*reshape(gb(36,beta(1),beta(2),beta(3)),[1,36^2]),2));

%can mess with guess to make it more reasonable. 
initialGuess = [20, 30 ,4];

mdl = fitnlm(X,Y,nonLinearModel,initialGuess);

% Extract fitted parameters
fittedParams = mdl.Coefficients.Estimate;

% Display results
disp('Fitted Parameters:');
disp(fittedParams);


% Specify the desired magnification factor
magnificationFactor = 4;  % Adjust this value as needed

% Resize the image
% resizedImage = imresize(smallImage, magnificationFactor, 'nearest');
%imshow(resizedImage,'InitialMagnification','fit');
figure
resizedImage1 = imresize(g, magnificationFactor, 'nearest');
imshow(mat2gray(resizedImage1));
title("original gabor");

figure
resizedImage2 = imresize(gb(36,fittedParams(1),fittedParams(2),fittedParams(3)), magnificationFactor, 'nearest');
imshow(mat2gray(resizedImage2));
title("Fitted gabor");


