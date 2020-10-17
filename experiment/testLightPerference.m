function [time_delay,centroid,CS_Position] = testLightPerference()

ROIPosition=[144 202 984 490];
vidobj = videoinput('gentl');  % ½µµÍÏñËØµã
vidobj.ROIPosition=ROIPosition;
triggerconfig(vidobj,'manual');
start(vidobj)

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
m=0;
time_delay=[];
centroid=zeros(2,48000);
CS_Position = zeros(1,4);
for i = 1:4
    if mod(i,2)==0
        ImgTexture=ImgTexture2;
        CS_Position(i) = 2;
    else
        ImgTexture=ImgTexture1;
        CS_Position(i) = 1;
    end
Screen('DrawTexture', window, ImgTexture, [], [], 0);   Screen('Flip', window); 
 
BgFrame = 600;
ImgStack = uint8(zeros(ROIPosition(4),ROIPosition(3),BgFrame));
for p = 1:BgFrame    
        tic
        snapshot = getsnapshot(vidobj);       % read one frame from vObj
        grayImg = im2uint8(snapshot);
        ImgStack(:,:,p) = grayImg;
        Pause_T = 0.1 - toc;
        pause(Pause_T);
end
Background = median(ImgStack,3);
clear ImgStack;

for t=1:12000
    tic
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

pause_T =0.1-toc;
if pause_T<0
    delay=[m;pause_T];
    time_delay=[time_delay,delay];
end
pause(pause_T);
end

end