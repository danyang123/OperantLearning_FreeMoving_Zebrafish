function [ Result ] = test_camera()
 ROIPosition=[648 364 616 255]; %imaging window


vidobj = videoinput('gentl');  % ½µµÍÏñËØµã
vidobj.ROIPosition=ROIPosition;
triggerconfig(vidobj,'manual');
start(vidobj)
for i=1:20
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
end
Result.sanpshot=snapshot;
Result.centroid=centroid;
end

