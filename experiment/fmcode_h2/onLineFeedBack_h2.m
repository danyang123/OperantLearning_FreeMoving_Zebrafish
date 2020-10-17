function fmData = onLineFeedBack_h2(window,ImgTexture)
% fmData:'free moving Data'/'fish master Data'

global  vidobj centroid  Background BgFrame ROIPosition yDivide
global  fs_frame time_delay trail_num m
global  DOPort   device  CMD  fish
global  window ImgTexture CS_Position

%% US
DevNo = 1;
DOPort = 2986;
delete(instrfindall)
K = DeviceQuery();
if isempty(K)
    warning('Not found STM32DAQ device. Program exit.');
    return;
end
for ii = 1:size(K,1)
    for jj = 1:size(K,2)
        if K(ii, jj) ~= 0
            continue;
        else
            dev(ii) = {K(ii, 1:(jj-1))};
            break;
        end
    end
end
device = serial(dev(DevNo),'baudrate',119200);
fopen(device);
CMD = zeros(1, 10, 'uint16');
CMD(1) = DOPort;

%% camera
ROIPosition=[656 809 896 407];
yDivide{1}=ROIPosition(4)/4;
yDivide{2}=ROIPosition(4)/4*3;

chamber_x(1)=0;
chamber_x(2)=ROIPosition(3)/2;
chamber_x(2)=ROIPosition(3);

chamber_y(1)=0;
chamber_y(2)=ROIPosition(4)/2;
chamber_y(2)=ROIPosition(4);

vidobj = videoinput('gentl');
vidobj.ROIPosition=ROIPosition;
triggerconfig(vidobj,'manual');
start(vidobj)
% Background1 =  getsnapshot(vidobj); Background=im2uint8(Background1);imshow(Background1);
CS_Position = zeros(1,60);

%% parameter
m=0; frame_num=14400;
centroid = zeros(8,frame_num);
BT_US=1;
Acq_US=2;
fs_frame=0.1;
for i=1:4
    fish{i}.us_top=[];
    fish{i}.us_bottom=[];
end
time_delay=[];
trail_num=0;
BgFrame = 300;
ImgStack = uint8(zeros(ROIPosition(4),ROIPosition(3),BgFrame));

%% Baseline
disp('Starting Baseline');
Experiment(BT_US);
pause(40+20);

%% Training
for i=1:5
    for p = 1:BgFrame
        tic
        snapshot = getsnapshot(vidobj);       % read one frame from vObj
        grayImg = im2uint8(snapshot);
        ImgStack(:,:,p) = grayImg;
        Pause_T = 0.1 - toc;
        pause(Pause_T);
    end
    Background = median(ImgStack,3);
    disp(['Starting Training ' num2str(i)]);
    Experiment(Acq_US)
    pause(270);
    
end
pause(40+260);


%% Test
disp('Starting Test');
Experiment(BT_US);

%% Close device
% sca;
delete(vidobj);
fclose(device);
delete(device);
clear device

%% Output
time_quality = 1-length(time_delay)/frame_num;

fmData.ROIPosition = ROIPosition;
fmData.FishStack = cell(4,1);
for i=1:2
    fmData.FishStack{i}.centroid = centroid(2*i-1:2*i,:);
    fmData.FishStack{i}.fs_frame = fs_frame;
    fmData.FishStack{i}.us_bottom = fish{i}.us_bottom;
    fmData.FishStack{i}.us_top = fish{i}.us_top;
    fmData.FishStack{i}.yDivide = yDivide(fix((i+1)/2));
    fmData.FishStack{i}.quality.centroid_quality = length(find(~isnan(centroid(2*i,:))))/frame_num;
    fmData.FishStack{i}.quality.time_quality = time_quality;
end
for i=1:trail_num
    if ~isempty(find([2 4],CS_Position(trail_num)))
        fmData.FishStack{1}.CS_Pattern(trail_num) = 2;
    else
        fmData.FishStack{1}.CS_Pattern(trail_num) = 1;
    end
    
    if ~isempty(find([3 4],CS_Position(trail_num)))
        fmData.FishStack{2}.CS_Pattern(trail_num) = 2;
    else
        fmData.FishStack{2}.CS_Pattern(trail_num) = 1;
    end
end

fmData.FishStack{1}.ROIPosition = [chamber_x(1),chamber_y(1);chamber_x(2),chamber_y(2)];
fmData.FishStack{2}.ROIPosition = [chamber_x(2),chamber_y(1);chamber_x(3),chamber_y(2)];

end

%% Experiment
function Experiment(US)
global   centroid Background BgFrame vidobj  ROIPosition yDivide
global  fs_frame time_delay trail_num m
global   device   CMD fish
global window ImgTexture CS_Position
PB6 = 1; PB7 = 2;  PB8 = 4; PB9 = 8;
ImgStack = uint8(zeros(ROIPosition(4),ROIPosition(3),BgFrame));
if US==1
    trail =15;
else
    trail=6;
end
for i=1:trail
    disp('Starting a trail...');
    trail_num = trail_num+1;
    
    if US==1
        for p = 1:BgFrame
            tic
            snapshot = getsnapshot(vidobj);       % read one frame from vObj
            grayImg = im2uint8(snapshot);
            ImgStack(:,:,p) = grayImg;
            Pause_T = 0.1 - toc;
            pause(Pause_T);
        end
        Background = median(ImgStack,3);
    end
    for t = 1:50   % non-CS and non-US
        tic
        ImageProcessing();
        pause_T = fs_frame-toc;
        if pause_T<0
            delay = [m;pause_T];
            time_delay = [time_delay,delay];
        end
        pause(pause_T);
    end
    
    Pattern = CS_Pattern();
    Screen('DrawTexture', window, ImgTexture(Pattern), [], [], 0);
    CS_Position(trail_num) = Pattern;
    Screen('Flip', window);
    
    for  t = 51:250  %101:148
        tic
        US1=0;  US2=0;  US3=0; US4=0;
        CMD(2) = 0;
        fwrite(device, CMD, 'uint16');
        ImageProcessing();
        if US==2 && t>110  && mod(t,20)==0  %  131
            %% chamber 1
            if (~isempty(find([1 3],Pattern))) && centroid(2,m)< yDivide(1)
                US1 = PB6;
                fish{1}.us_bottom=[fish{1}.us_bottom,m];
            elseif (~isempty(find([2 4],Pattern))) && centroid(1,m)>yDivide(2)
                US2 = PB7;
                fish{1}.us_top = [fish{1}.us_top,m];
            end
            %% chamber 2
            if (~isempty(find([1 2],Pattern)) ) && centroid(2,m)< yDivide(1)
                US3 = PB8;
                fish{2}.us_bottom=[fish{2}.us_bottom,m];
            elseif (~isempty(find([3 4],Pattern ))) && centroid(1,m)>yDivide(2)
                US4 = PB9;
                fish{2}.us_top = [fish{2}.us_top,m];
                
            end
            CMD(2) = US1 + US2 + US3 + US4;
            fwrite(device, CMD, 'uint16');
        end
         
        pause_T =fs_frame-toc;
        if pause_T<0
            delay=[m;pause_T];
            time_delay=[time_delay,delay];
        end
        pause(pause_T);
    end
    
    Screen('FillRect', window, [0 0 0]);
    Screen('DrawingFinished', window);
    Screen('Flip', window);
    for  t = 251:300  %161:200
        tic
        ImageProcessing();
        pause_T =fs_frame-toc;
        if pause_T<0
            delay=[m;pause_T];
            time_delay=[time_delay,delay];
        end
        pause(pause_T);
    end
    
end
end

function ImageProcessing()
global  m vidobj centroid Background
m=m+1;
snapshot = getsnapshot(vidobj);
grayImg =im2uint8( snapshot);
Img1= Background -grayImg;
Img = im2double(Img1);
BW = imbinarize(Img,0.06);
bwFish = bwareaopen(BW,120);
s=regionprops(bwFish,'centroid');
centroid_raw = S.Centroid';
fish=cell(4,1);
for i=1:4
    fish{i}.centroid=[];
end
for i = 1:length(s.centroid')
    
    if centroid_raw(2,i)<chamber_y(2)
        fish{1}.centroid=[fish{1}.centroid,centroid_raw(1,i)];
    else
        fish{2}.centroid=[fish{2}.centroid,centroid_raw(1,i)];
    end
    
end
for i = 1:2
    if length(fish{i}.centroid)~=1
        centroid(i*2-1:i*2,m)=[nan;nan];
    else
        centroid(i*2-1:i*2,m)=fish{i}.centroid;
        
    end
end
end

function Pattern = CS_Pattern()
global m yDivide centroid
if centroid(2,m)< yDivide(1)&& centroid(4,m)< yDivide(1)
    Pattern = 1;
end
if centroid(2,m)> yDivide(1)&& centroid(4,m)< yDivide(1)
    Pattern = 2;
end
if centroid(2,m)< yDivide(1)&& centroid(4,m)> yDivide(1)
    Pattern = 3;
end
if centroid(2,m)> yDivide(1)&& centroid(4,m)> yDivide(1)
    Pattern = 4;
end
end