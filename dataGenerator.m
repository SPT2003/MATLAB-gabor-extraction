clc; close all; clear all


%fake data.txt
f = fopen("fakeData.txt","w");
%for loop. to generate random white noise. 

for i = 1:10000
    whiteNoiseImage = randn(12);
    I = whiteNoiseImage;
    Istore = I(:)';
    g=gb(12,7, 90, 3.5);
    outMag = I.*g;

    %outmag is the result from applying the filter to the sample image. 

    %getting the sum of the outMag matrix. 
    result = sum(outMag,"all");
    %half wave rectification. 
    if result < 0 
        result = 0;
    end

    %using poisson rng to generate a spike count. 
    spikeCout = poissrnd(result);
    %printing the image data and spike coutns to fakedata.txt
    fprintf(f,"%.4f ",Istore);
    fprintf(f,"%d\n",spikeCout);
end

%closing file. 
fclose(f);