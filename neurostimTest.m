clc; close all; clear all

%%
%having a look at the eye data. 
eyedata = edfmex('C:\Users\erict\Downloads\M1899_utimages_example\m1899.utimages.111300.edf');

% data is in samples - sampling rate is 1000 samples/sec
% plot the x and y eye trace from the first 10e3 samples
samples = 1:10e3; % first 10 seconds of eye trace data
eyeNum = 2; % plot data from the left eye
figure; hold on;
plot(eyedata.FSAMPLE.time(samples),eyedata.FSAMPLE.px(eyeNum,samples),'-b') % horizontal eye position
plot(eyedata.FSAMPLE.time(samples),eyedata.FSAMPLE.py(eyeNum,samples),'-r') % vertical eye position
hold off
%%

data = load('C:\Users\erict\Downloads\M1899_utimages_example\m1899.utimages.111300.mat');
a = data.c;
%%
%loading in data along with the 
d = marmodata.mdbase('C:\Users\erict\Downloads\M1899_utimages_example\m1899.utimages.111300.mat','loadArgs',{'loadEye',true,'spikes',true','source','ghetto'})
%%
dd = freeviewing.analysis.utimages(d);
%%
%having a play around with the different functions. 
clc
condID = dd.getConds();
eyeTrace = dd.getEyeVelocity();
fix = dd.getFixations();
saccades = dd.getSaccades();
%salMap = dd.getSaliencyMap('trialIds',1,'imgdatabaseloc','C:\Users\erict\Downloads\Marmolab\UT Natural Images\Campus Scene Collection - Set 1'); %needs the image of the trial. 
Img = dd.getTrialImg('trialIds',1,'imgdatabaseloc','C:\Users\erict\Downloads\Marmolab\UT Natural Images\Campus Scene Collection - Set 1');
trace = dd.getXYEyetrace(1);
%%
%checking that eye traces work and make sense. ut images analysis function,
%has pixelsperdeg set to 1 for plotting. 
dd.plotEyeTraces('trialIds',1,'imgdatabaseloc','C:\Users\erict\Downloads\Marmolab\UT Natural Images');


%%
%this gets me the stuff for fix X, fix Y and spikerate. Modified the
%function in utimages to save those desired variables into the base
%workspace
dd.plotSaccadeRFmap(1);

%%
%run this section to see what the key is in each condition, basically check
%the trial number and associated image name. 
% Assuming dd.conds is your cell array
for i = 1:numel(dd.conds)
    % Access the struct within the cell
    currentStruct = dd.conds{i};
    
    % Check if the struct has the 'key' field
    if isfield(currentStruct, 'key')
        % Access the value of the 'key' field
        keyValue = currentStruct.key;
        
        % Print the value
        fprintf('Value of key in cell %d: %s\n', i, keyValue);
    else
        % Handle the case where 'key' field is not present
        fprintf('No key field in cell %d\n', i);
    end
end


%%
%this is the experimenting section running the algo for one trial. 

%No need to run this section. 
clc

%ignore 0 spike rate fixations. 
nzspike = spikerate(spikerate>0);
nzspikeX = fixX((spikerate > 0));
nzspikeY = fixY((spikerate > 0));

        % general info for all trials:
        rec = dd.meta.image.filename('time',Inf).data;
        width = dd.meta.image.width('time',Inf).data; width = width(1);
        height = dd.meta.image.height('time',Inf).data; height = height(1);
        screen = dd.meta.cic.screen('time',Inf).data; screen = screen{1};
        
        pixelsperdeg = 1;
        pixelxzero = screen.xpixels/2;
        pixelyzero = screen.ypixels/2;

        X = nzspikeX .* pixelsperdeg + pixelxzero;
        Y =  nzspikeY.* -pixelsperdeg + pixelyzero;
        %XX and YY are the fixations that are not too close to the edge of
        %image. 
         XX = X((X> 350) & (X < 1920 -350) & (Y > 150) & (Y<1080-150));
        
         YY = Y((X> 350) & (X < 1920 -350) & (Y > 150) & (Y<1080-150));

         nzspike = nzspike((X> 350) & (X < 1920 -350) & (Y > 150) & (Y<1080-150));


figure
imagesc(nthroot(Img{1},2.2));
colormap('gray');
hold on
plot(XX, YY,'o','Color','r','MarkerFaceColor',[1 1 1],'MarkerSize',8)
hold off


%%
%cut out small slices, from the image based on the locations of the image.
%continuation of the previous section, just getting the weighting down. 

%image is the 
image = nthroot(Img{1},2.2);

gabor = zeros(50);

weightedSum = sum(nzspike);

for i=1:numel(XX)
    %takes each coordinate pair of XX and YY. Where XX is the columns and
    %YY are the rows

    %Column and Row are the top left corner of the fixation image.  
    column = round(XX(i))-24;
    row = round(YY(i))-24;

    smallimage = image(row:row+49,column:column+49);

    gabor = gabor + nzspike(i)/weightedSum*smallimage;




end
figure
imagesc(gabor);
colormap('gray');

%%
%running the pipeline for all images in this trial. 
list = [];
%list contains all the trial keys that do not have contradicting keys and
%image names. 
for i = 1:numel(dd.condIds)
    try
        Img = dd.getTrialImg('trialIds',dd.condIds(i),'imgdatabaseloc','C:\Users\erict\Downloads\Marmolab\UT Natural Images\Campus Scene Collection - Set 1');
        list = [list,dd.condIds(i)];
    catch
        continue
    end
end
%%
weightedSum = 0;
gabor = zeros(50);
counter = 0;
for i=1:numel(list)
    %plotSaccadeRFmap gives me spikerate,fixx,fixY variables for trial i. 
    dd.plotSaccadeRFmap(list(i));
    %finding the weighted sum of all the trials that I am interestedin. 
    weightedSum = weightedSum + nansum(spikerate);
end

for i = 1:numel(list)
    dd.plotSaccadeRFmap(list(i));
    fprintf("The image name is. %d",list(i));
    Img = dd.getTrialImg('trialIds',list(i),'imgdatabaseloc','C:\Users\erict\Downloads\Marmolab\UT Natural Images\Campus Scene Collection - Set 1');
    image = nthroot(Img{1},2.2);
    nzspike = spikerate(spikerate>0);
    nzspikeX = fixX((spikerate > 0));
    nzspikeY = fixY((spikerate > 0));

     % general info for all trials:
     rec = dd.meta.image.filename('time',Inf).data;
     width = dd.meta.image.width('time',Inf).data; width = width(1);
     height = dd.meta.image.height('time',Inf).data; height = height(1);
     screen = dd.meta.cic.screen('time',Inf).data; screen = screen{1};
        
     pixelsperdeg = 1;
     pixelxzero = screen.xpixels/2;
     pixelyzero = screen.ypixels/2;

     X = nzspikeX .* pixelsperdeg + pixelxzero;
     Y =  nzspikeY.* -pixelsperdeg + pixelyzero;

     XX = X((X> 350) & (X < 1920 -350) & (Y > 150) & (Y<1080-150));
        
     YY = Y((X> 350) & (X < 1920 -350) & (Y > 150) & (Y<1080-150));

     nzspike = nzspike((X> 350) & (X < 1920 -350) & (Y > 150) & (Y<1080-150));
     % figure
     % imagesc(nthroot(Img{1},2.2));
     % colormap('gray');
     % hold on
     % plot(XX, YY,'o','Color','r','MarkerFaceColor',[1 1 1],'MarkerSize',8)
     % hold off
     % pause(0.5);
     for j=1:numel(XX)
        %takes each coordinate pair of XX and YY. Where XX is the columns and
        %YY are the rows

        %Column and Row are the top left corner of the fixation image.  
        column = round(XX(j))-24;
        row = round(YY(j))-24;

        smallimage = image(row:row+49,column:column+49);

        gabor = gabor + (nzspike(j))/weightedSum*smallimage;
        %gabor = gabor + mean(nzspike)/weightedSum*smallimage;
        counter = counter + 1;




     end
     fprintf("image %d done\n",i);
end

figure
imagesc(gabor);
colormap('gray');

