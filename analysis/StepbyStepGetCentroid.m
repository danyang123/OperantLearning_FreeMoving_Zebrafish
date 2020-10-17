
ROIPosition=[144 202 984 490];
xDivide=ROIPosition(3)/2;
vidobj = videoinput('gentl');  % ½µµÍÏñËØµã
vidobj.ROIPosition=ROIPosition;
triggerconfig(vidobj,'manual');
start(vidobj)

BgFrame = 400; 
for p = 1:BgFrame    
        tic
        snapshot = getsnapshot(vidobj);       % read one frame from vObj
        grayImg = im2uint8(snapshot);
        ImgStack(:,:,p) = grayImg;
        Pause_T = 0.1 - toc;
        pause(Pause_T);
end
Background = median(ImgStack,3);
imshow(Background);
snapshot = getsnapshot(vidobj);
grayImg =im2uint8( snapshot);
imshow(grayImg);
Img1= Background -grayImg;
imshow(Img1);
Img = im2double(Img1);
BW = imbinarize(Img,0.06);
imshow(BW);
bwFish = bwareaopen(BW,120);
imshow(bwFish);
s=regionprops(bwFish,'centroid');
centroid=s.Centroid'; 
        
imshow(bwFish);
hold on
scatter(centroid(1,1),centroid(2,1),25,'r','filled');