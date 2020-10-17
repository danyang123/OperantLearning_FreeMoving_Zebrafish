function Result = onLineFeedBack_new()
global window ImgTexture1 ImgTexture2 CS_Position  % Projector
global vidobj centroid Background BgFrame ROIPosition xDivide   % Camera, Centroid
global fs_frame time_delay trail_num m   % Timer
global DOPort us_left  us_right  device  CMD  % US

%% Projector
screen_coordinate=[1921 0 2945 768]; 
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
load('C:\Users\TeleoCam\Desktop\Img.mat');
Img1 = Img{1};
Img2 = Img{2};
[window, ~] = PsychImaging('OpenWindow', screenNumber,[0,0,0],screen_coordinate);
Screen('DrawingFinished', window);
Screen('Preference', 'SkipSyncTests', 0);
ImgTexture1 = Screen('MakeTexture', window, Img1);
ImgTexture2 = Screen('MakeTexture', window, Img2);
% ImgTexture=ImgTexture2; 
% Screen('DrawTexture', window, ImgTexture2, [], [], 0);   Screen('Flip', window);

%% US
DevNo = 1;					% 使用第一个设备
DOPort = 2986;				% DO Port输出，对应的16进制里面的BAA，目的是信号保真，只有符合AADC信号才可以通过，B是选择对应的程序，相当于内部有不同的函数，使用第一个函数				% DI Port输入
delete(instrfindall)
K = DeviceQuery();
if isempty(K)
	warning('Not found STM32DAQ device. Program exit.');
	return;
end
for ii = 1:size(K,1)
	for jj = 1:size(K,2)
		if K(ii, jj) ~= 0
            continue;						% 跳过所有的有效字符
        else
            dev(ii) = {K(ii, 1:(jj-1))};	% 遇到无效字符，截断，取前面有效的部分放到元胞数组中。
			break;
		end
	end
end
device = serial(dev(DevNo),'baudrate',119200);
fopen(device);
CMD = zeros(1, 10, 'uint16');
CMD(1) = DOPort;		

%% camera
ROIPosition=[160 192 976 475];
xDivide=ROIPosition(3)/2;
vidobj = videoinput('gentl');  % 降低像素点
vidobj.ROIPosition=ROIPosition;
triggerconfig(vidobj,'manual');
start(vidobj)
% Background1 =  getsnapshot(vidobj); Background=im2uint8(Background1);imshow(Background1);
CS_Position = zeros(1,42);

%% parameter
m=0; frame_num=8400;
centroid=zeros(2,frame_num);
BT_US=1;  % 1 means that don't carry out US
Acq_US=2;  % 2 means that carry out US
fs_frame=0.1;
us_right=[]; us_left=[];
time_delay=[];
trail_num=0;  
BgFrame = 400;
ImgStack = uint8(zeros(ROIPosition(4),ROIPosition(3),BgFrame));

%% Baseline
disp('Starting Beseline');
Experiment(BT_US);
pause(60);

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
     pause(260);
     
end
pause(300); 

 
%% Test
disp('Starting Test');
Experiment(BT_US);

%% Close device
sca;           
delete(vidobj);
fclose(device);
delete(device);
clear device

%% Output
centroid_quality=length(find(~isnan(centroid(1,:))))/frame_num;
time_quality=1-length(time_delay)/frame_num;
Result.centroid=centroid;
Result.CS_Position=CS_Position;
Result.fs_frame=fs_frame;
Result.ROIPosition=ROIPosition;
Result.US.us_left=us_left;
Result.US.us_right=us_right;
Result.xDivide=xDivide;
Result.quality.centroid_quality=centroid_quality; 
Result.quality.time_quality=time_quality;
Result.quality.time_delay=time_delay;
%Result.snapshot = snapshot;

end

%% Experiment
function Experiment(US)
global  centroid Background BgFrame vidobj  ROIPosition xDivide
global  fs_frame time_delay trail_num m
global  us_left us_right device CMD
global  window ImgTexture1 ImgTexture2 CS_Position
PB6 = 1; PB7 = 2;
ImgStack = uint8(zeros(ROIPosition(4),ROIPosition(3),BgFrame));
for i=1:6
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
   for t = 1:70 
       tic
       ImageProcessing();
       pause_T = fs_frame-toc;
         if pause_T<0
             delay = [m;pause_T];
             time_delay = [time_delay,delay];
         end
       pause(pause_T);
   end

   if centroid(1,m)< xDivide
       Screen('DrawTexture', window, ImgTexture1, [], [], 0);
       CS_Position(trail_num) = 1;
       CS_Flag=1;
   else
       Screen('DrawTexture', window, ImgTexture2, [], [], 0);
       CS_Position(trail_num) = 2;
       CS_Flag=2;
   end
   Screen('Flip', window);
   
   for  t = 71:130  
       tic
       ImageProcessing();
       if US==2 && t>99  && mod(t,5)==0  %  131 
           if  CS_Flag==1 && centroid(1,m)< xDivide
               CMD(2) = PB6;
               fwrite(device, CMD, 'uint16');
               us_left=[us_left,m];
           elseif CS_Flag==2 && centroid(1,m)>xDivide
               CMD(2) = PB7;
               us_right=[us_right,m];
               fwrite(device, CMD, 'uint16');
           end
           CMD(2) = 0;
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
   for  t = 131:200  
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
       if size(s,1)~=1
           centroid(:,m)=[nan;nan];
       else
           centroid(:,m)=s.Centroid'; 
       end
end

