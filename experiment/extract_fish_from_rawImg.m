function extract_fish_from_rawImg()
% extract the two fish from the image at each frame
% 读入视频，更新背景，得到frontImg,再得到每一帧的二值图，除去背景里的小的连通区域
% imerode,imdilate,算出质心，算出头

%% Read the video frame by frame
[f,p] = uigetfile('*.avi');  
fName = [p,f];
v0bj = VideoReader(fName);
numFrame = 1000;
BgFrame = 200;
n = 0;
ImgStack = zeros(v0bj.Height,v0bj.Width,BgFrame);


%% get the first two hundred ImgStack
for i = 1:BgFrame                 
    frame = readFrame(v0bj);       % read one frame from vObj
    grayImg = rgb2gray(frame);
    ImgStack(:,:,i) = grayImg;
end


%% updata mean background image,get and imshow bwfish
for i = 701:1000         
     n = n+1;         %meaningless,used for counting   
     frame = readFrame(v0bj);
     grayImg = rgb2gray(frame);
     [meanBg,ImgStack] = update_meanBg(grayImg,ImgStack); 
     frontImg = double(grayImg) - meanBg;     %get frontImg
     Img1=frontImg.*(-1);               %Convert image to binary image
     idx = find(Img1<0);      
     Img1(idx)=0;
     Img = Img1./10;
      BW = imbinarize(Img,0.6);
      

%% erode and dilate to get smooth outlines
       %se = strel('disk',2);
       %erodedI = imerode(BW,se);
       % se1 = strel('disk',3);
       %  dilatedI = imdilate(erodedI,se1);
       %   bwFish = bwareaopen(dilatedI,600);   %Remove small objects from binary image 
       
      bwFish = bwareaopen(BW,600); 
 %% scatter the bary centers of two fishes 
       s = regionprops( bwFish,'centroid');
       centroids = cat(1, s.Centroid);
       figure(1);
       imshow(bwFish,[]);
       hold on;
       scatter(centroids(:,1),centroids(:,2),10,'b','filled')
       disp(n);
       pause(0.1);
      

%% scatter the heads of the two fishes     
       [B,L] = bwboundaries(bwFish,'noholes');
      
       L = bwlabel(bwFish);   %get the points of two fishes
       [fish1_x, fish1_y] = find(L==1);
       fish1=[fish1_x,fish1_y]';
       [fish2_x, fish2_y] = find(L==2);
       fish2=[fish2_x,fish2_y]';        
       C=B{1,1};
       head1 = find_head(C,fish1);
       scatter(head1(2,1),head1(1,1),10,'r','filled')
       pause(0.1);
       D=B{2,1};
       head2 = find_head(D,fish2);     
       scatter(head2(2,1),head2(1,1),10,'r','filled')
       pause(0.1);
      
end
      
end

     
%% function: updata mean background image 
function [meanBg,ImgStack]=update_meanBg(grayImg,ImgStack)
    ImgStack(:,:,1)=[];
    ImgStack=cat(3,ImgStack,grayImg);
    meanBg=mean(ImgStack,3);
end

%% function:get the point of head 
function head = find_head(B,fish)
       c = minBoundingBox(B');
       C = zeros(2,1);
       C(1) = norm(c(:,1)-c(:,2));
       C(2) = norm(c(:,1)-c(:,4));
       min_norm_c=min(C);
       if min_norm_c==C(1)
           f1=c(:,1);  f2=c(:,2); f3=c(:,3);f4=c(:,4);
       else     
           f1=c(:,2);  f2=c(:,3); f3=c(:,4);f4=c(:,1);
       end
       f1_m = (f1+f2)./2;   f2_m=(f3+f4)./2;
       f3_m = (f2+f3)./2;   f4_m=(f4+f1)./2;
        [f_mid,D]=find_D(fish,f1_m,f2_m,f3_m,f4_m);
        D_norm=sqrt(D(1,:).^2+D(2,:).^2);
       min_D_norm=min(D_norm);
       idx=find(D_norm==min_D_norm);
       head=D(:,idx)+f_mid;
end

%% get a matrix of distance and f_mid
function  [f_mid,D]=find_D(fish,f1_m,f2_m,f3_m,f4_m)
       k=(f3_m(1,1)- f4_m(1,1))./(f3_m(2,1)- f4_m(2,1));
       b=f3_m(1,1)-k.*f3_m(2,1); 
       if f3_m(2,1)== f4_m(2,1)
           num1=length(find(fish(2,:)-f3_m(2,1)<0));
           num2=length(find(fish(2,:)-f3_m(2,1)>0));
           if num1>num2
               if f1_m(2,1)<f2_m(2,1)
                   f_mid=f1_m;    D=fish-f1_m;
               else
                    f_mid=f2_m;   D=fish-f2_m;
               end
           else
               if  f1_m(2,1)>f2_m(2,1)
                    f_mid=f1_m;    D=fish-f1_m;
               else
                    f_mid=f2_m;     D=fish-f2_m;
               end
           end
      
       else
       num1=length(find(k.*fish(2,:)+b-fish(1,:)<0));
       num2=length(find(k.*fish(2,:)+b-fish(1,:)>0));
         if num1>num2
            if  f1_m(1,1)> f2_m(1,1)
                  f_mid=f1_m;    D=fish-f1_m;
            else
                   f_mid=f2_m;   D=fish-f2_m;
            end
         else
           if  f1_m(1,1)<f2_m(1,1)
                   f_mid=f1_m;   D=fish-f1_m;
           else
                   f_mid=f1_m;   D=fish-f2_m;
           end
         end
       end
      
end