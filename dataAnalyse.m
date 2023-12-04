%finding the gabor shape. 
clc; close all; clear all
f = fopen('fakeData.txt',"r");

%saving the data back into a readable matrix. 
data = zeros(10000,145,"double");

%1 thousand image entries
for i = 1:10000
    %get a line
    line = fgetl(f);
    %seperate them into floats
    val = sscanf(line,"%f");
    %make the array 1x145 double
    val = val';
    %join the array together. 
    for j = 1:145
        data(i,j) = val(j);
    end
end
fclose(f);

%summed value of the spikes
weight = sum(data(:,145));

%gabor estimate matrix. 
gE = zeros(1,144);

%summing the images with the weighting factor
for i = 1:10000
    gE = gE + data(i,145)/weight*data(i,1:144);
end


%reshaping the image, 
gE = reshape(gE,12,12);




% Specify the desired magnification factor
magnificationFactor = 4;  % Adjust this value as needed

% Resize the image
resizedImage = imresize(gE, magnificationFactor, 'nearest');

% Display the resized image
figure
imshow(resizedImage, 'InitialMagnification', 'fit',"Colormap",gray);
title('Resized Image');



%optimisation of mathematical model. 

%model = @(l,t,s) sum(gE.*gb(12,l,t,s),"all"); ignore this line for now. 

%100 values for the different parameters of the gabor, I did not use a
%variable for image size as that is assumed to be constant. 
lambda = linspace(0,12,100);
theta = linspace(0,360,100);
sigma = linspace(0,4,100);

%possible values = rows = 100^3
result_matrix = zeros(100^3,4);

%row indexing starting with 1. 
in = 1;
for l = lambda
    for t = theta
        for s = sigma
            result_matrix(in,1) = l;
            result_matrix(in,2) = t;
            result_matrix(in,3) = s;
            %correlation between the resulting averaged image and the
            %tested gabor. 
            result_matrix(in,4) = corr2(gE,gb(12,l,t,s));

            in = in + 1;
        end
    end
end

%finding the gabor that gave the best result. 
[M,I] = max(result_matrix(:,4));


%printing out the results. 
result_matrix(I,1)
result_matrix(I,2)
result_matrix(I,3)
result_matrix(I,4)




