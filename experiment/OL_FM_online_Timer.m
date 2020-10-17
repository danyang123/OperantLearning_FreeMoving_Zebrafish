function Result = OL_FM_online()
global screens screenNumber ifi %projector
global time trial screen_coordinate window windowRect xDivide fs_frame% para
global snapshot vidobj %imaging
global centroid CS_Position CS_Position_lag time_point_ind time_point %results
global HFIG DISPLAY START STOPPED LAP LAPFLAG %counter
global ISUS ImgTexture1 ImgTexture2
global PB6 PB7 DOPort us_left  us_num_L us_right  us_num_R device us_end us_end_num

%% Timer
fs_frame=0.2;
time.per_cycle=20;  %/s %每个循环多少秒:只拍20s，第10s开始
time.cs_start=10;   % 每个trail的第几秒开始CS
time.cs_end=14.8;    % 第几秒结束CS
time.us_start=13.2;  %第几秒开始US
time.us_end=14.8;
time.hab_trial_Interval=40; % /s
time.acq_trial_Interval=0.01;
time.tst_trial_Interval=40;
time.hab_acq_Interval=1*60;  %1min
time.acq_block_Interval=5*60;  %5min
time.acq_tst_Interval=10*60;  %10min

trial.hab=6;
trial.acq_block_num=5;
trial.acq_block_trial=6;
trial.test=6;
trial.total_num=trial.hab+trial.acq_block_num*trial.acq_block_trial+trial.test;

%% Clock panel
HFIG = figure('Name', '秒表计时器', 'Numbertitle', 'off', 'Position', [400 300 350 100], ...
    'Menubar', 'none', 'Resize', 'off', 'KeyPressFcn', [mfilename, '(''KEY'')']);
START = uicontrol(HFIG, 'Style', 'PushButton', 'Position', [10 10 75 25], ...
    'String', '开始', 'Callback', [mfilename, '(''START'')']);
LAP = uicontrol(HFIG, 'Style', 'PushButton', 'Position', [95 10 75 25], ...
    'String', '计时 (L)', 'Callback', [mfilename, '(''LAP'')'], 'Enable', 'off');
DISPLAY = uicontrol(HFIG, 'Style', 'text', 'Position', [25 45 300 55], ...
    'BackgroundColor', [0.8 0.8 0.8], 'FontSize', 35, 'String', '00:00:00.000');

%% Projector
screen_coordinate=[2180 100 2780 700]; %projector
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
load('C:\Users\TeleoCam\Desktop\Img.mat');
Img1 = Img{1};
Img2 = Img{2};
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,[0,0,0],screen_coordinate);
Screen('DrawingFinished', window);
Screen('Preference', 'SkipSyncTests', 0);
ifi = Screen('GetFlipInterval', window);
ImgTexture1 = Screen('MakeTexture', window, Img1);
ImgTexture2 = Screen('MakeTexture', window, Img2);
ImgTexture=ImgTexture2; 
Screen('DrawTexture', window, ImgTexture, [], [], 0);   
Screen('Flip', window);

%% Camera
ROIPosition=[632 405 640 260]; %imaging window
xDivide=ROIPosition(3)/2;

vidobj = videoinput('gentl');  % 降低像素点
vidobj.ROIPosition=ROIPosition;
triggerconfig(vidobj,'manual');
start(vidobj)

%% US
DevNo = 1;					% 使用第一个设备
PB6 = 1; PB7 = 2;
DOPort = 2986;				% DO Port输出，对应的16进制里面的BAA，目的是信号保真，只有符合AADC信号才可以通过，B是选择对应的程序，相当于内部有不同的函数，使用第一个函数
DIPort = 1194;				% DI Port输入
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

%% main
time_point_ind=0;
time_point=zeros(time.per_cycle*trial.total_num,1);
%snapshot=uint8(zeros((ROIPosition(4)-ROIPosition(2)),(ROIPosition(3)-ROIPosition(1)),(time.per_cycle*trial.total_num)/fs_frame));
centroid = zeros(2,time.per_cycle*trial.total_num);
CS_Position = [];
CS_Position_lag='left';
STOPPED=1;
us_left=[];  us_num_L=0;  us_right=[];  us_num_R=0; us_end=[];  us_end_num=0;
for S=1:2+trial.acq_block_num
    tic;
    disp(['starting session ' num2str(S)]);
    switch S
        case 1       %Baseline  1
            ISUS=0;
            mytimer = createTimer(time.per_cycle,time.hab_trial_Interval,trial.hab,time.hab_acq_Interval);
            start(mytimer);
            wait(mytimer);
            delete(mytimer);
        case [mat2cell([2:trial.acq_block_num]',ones(trial.acq_block_num-1,1))]'  %Training前4个Block  mat2cell((2:5)',ones(4,1))'
            ISUS=1;
            mytimer = createTimer(time.per_cycle,time.acq_trial_Interval,trial.acq_block_trial,time.acq_block_Interval);
            start(mytimer);
            wait(mytimer);
            delete(mytimer);
            %pause(time.acq_block_Interval);
        case trial.acq_block_num+1   %Training最后一个Block 6
            ISUS=1;
            mytimer = createTimer(time.per_cycle,time.acq_trial_Interval,trial.acq_block_trial,time.acq_tst_Interval);
            start(mytimer);
            wait(mytimer);
            delete(mytimer);
            %pause(time.acq_tst_Interval);
        case 2+trial.acq_block_num   %Test  7
            ISUS=0;
            mytimer = createTimer(time.per_cycle,time.tst_trial_Interval,trial.test,0);
            start(mytimer);
            wait(mytimer);
            delete(mytimer);
    end
end
quality=length(find(~isnan(centroid(1,:))))/length(centroid(1,:));
sca;           
close(HFIG);
delete(vidobj);

fclose(device);
delete(device);
clear device

Result.centroid=centroid;
Result.CS_Position=CS_Position;
Result.fs_frame=fs_frame;
Result.POIPosition=ROIPosition;
Result.time=time;
Result.US.us_left=us_left;
Result.US.us_right=us_right;
Result.xDivide=xDivide;
Result.quality=quality; 
Result.snapshot = snapshot;
end


%% functions
function t = createTimer(time_per_cycle,trial_Interval,total_num,session_Interval)
%global time
t = timer;
t.UserData = time_per_cycle; % /s
t.StartFcn = @TimerStart;
t.TimerFcn = @TimerF;
t.StopFcn = {@TimerCleanup,session_Interval};
t.Period = trial_Interval; % /s
t.StartDelay = 1; % /s
t.TasksToExecute = total_num;
if t.TasksToExecute >1
    t.ExecutionMode = 'fixedSpacing';
else
    t.ExecutionMode = 'singleShot';
end
end

function TimerStart(mTimer,~)
str1 = 'Starting Timer.  ';
str2 = sprintf('For the next %d s start task',...
    mTimer.StartDelay);
str3 = sprintf(' to take a %d s interval every %d s. with %d trials',...
    mTimer.Period, mTimer.UserData,mTimer.TasksToExecute);
disp([str1 str2 str3])
end

function TimerF(mTimer,~)
global  window fs_frame time ISUS  xDivide ImgTexture1 ImgTexture2
global  DISPLAY START  LAP STOPPED
global centroid time_point_ind time_point CS_Position_lag CS_Position
global snapshot vidobj
global PB6 PB7 DOPort us_left  us_num_L us_right  us_num_R device us_end us_end_num
%global fs_time

fs_time=0;STOPPED = 0;
disp('Starting a trial...')
if CS_Position_lag==1
    CS_Position_lag=0;
    ImgTexture=ImgTexture1;
else
    CS_Position_lag=1;
    ImgTexture=ImgTexture2;
end
TIME=0;
cs_on=1;cs_off=1;us_on=1;us_off=1;US_Flag=0;
tic;
while TIME<mTimer.UserData &&~STOPPED
    t = toc;
    tic;
    TIME = TIME + t;
    set(START, 'Enable', 'off');%
    set(LAP, 'Enable', 'on');
    str = format_time(TIME); set(DISPLAY, 'String', str);
    if ceil(TIME/fs_frame)>= (fs_time+1)
       time_point_ind=time_point_ind+1;
       
       %getimgcentroid();
       snapshot(:,:,time_point_ind)  = getsnapshot(vidobj);
       Img = im2double(snapshot(:,:,time_point_ind) );
       BW = imbinarize(Img,0.7);
       BW2 = bwareaopen(BW,100);
       BW2=BW2*(-1) +1;
       BW1 = bwareaopen(BW2,10000);
       bwfish = BW2-BW1;
       bwFish = bwareaopen(bwfish,100);
       s=regionprops(bwFish,'centroid');
       if size(s,1)~=1
           centroid(:,time_point_ind)=[nan;nan];
       else
           centroid(:,time_point_ind)=s.Centroid'; 
       end
       fish_loc=centroid(1,time_point_ind);    
       if ISUS
           if fish_loc< xDivide
               ImgTexture=ImgTexture1; CS_Position_lag=0; 
           else
               ImgTexture=ImgTexture2; CS_Position_lag=1; 
           end
           if abs(TIME-time.us_start)<=fs_frame && us_on==1
               if fish_loc< xDivide
                   
                   CMD(2) = PB6;  %右
                   US_Flag=1;
                   us_num_L=us_num_L+1;
                   us_left(us_num_L)=time_point_ind;
               else
                   CMD(1) = DOPort;
                   CMD(2) = PB7;   %左
                   US_Flag=2;
                   us_num_R=us_num_R+1;
                   us_right(us_num_R)=time_point_ind;
               end
           us_on=us_on+1;        
           fwrite(device, CMD, 'uint16');  
           end    
           if  (abs(TIME-time.us_end)<=fs_frame || (US_Flag==1 && fish_loc> xDivide) ||( US_Flag==2 && fish_loc<xDivide)) && us_off==1
               
               CMD(2) = 0;
               fwrite(device, CMD, 'uint16');
               us_off=us_off+1;
               us_end_num=us_end_num+1;
               us_end(us_end_num)=time_point_ind;
           end
           
           
       end
       if abs(TIME-time.cs_start)<=fs_frame && cs_on==1 %&& mod(TIME,ifi)==0
            Screen('DrawTexture', window, ImgTexture, [], [], 0);   
            Screen('Flip', window);
            cs_on=cs_on+1;  
            CS_Position=[CS_Position;CS_Position_lag];
       elseif abs(TIME-time.cs_end)<=fs_frame && cs_off==1 %&& mod(TIME,ifi)==0
            Screen('FillRect', window, [0 0 0]);
            Screen('Flip', window);
            cs_off=cs_off+1;
       end

     
        fs_time=ceil(TIME/fs_frame);
        time_point(time_point_ind)=TIME;
        pause(0.01);
    else
        continue;
    end
end
STOPPED=1;
end

function TimerCleanup(mTimer,~,session_Interval)
global HFIG STOPPED
disp('Stopping Timer.');
fprintf('Waiting %d s to start next session\n',session_Interval)
%delete(mTimer);
STOPPED=1;
pause(session_Interval);
%sca;
%close(HFIG);
end


function [str] = format_time(t)
hrs = floor(t/3600);
min = floor(t/60 - 60*hrs);
sec = t - 60*(min + 60*hrs);
if hrs < 10
    h = sprintf('0%1.0f:', hrs);
else
    h = sprintf('%1.0f:', hrs);
end
if min < 10
    m = sprintf('0%1.0f:', min);
else
    m = sprintf('%1.0f:', min);
end
if sec < 9.9995
    s = sprintf('0%1.3f', sec);
else
    s = sprintf('%1.3f', sec);
end
str = [h m s];
end