figure;
BT_x{1}=[0 3000 3000 0];
BT_y=[0 0 55 55];
BT_x{2}=[9000 12000 12000 9000];
fill(BT_x{1},BT_y,[0.5 0.5 0.5], 'FaceAlpha',0.4,'LineStyle','none');
hold on
fill(BT_x{2},BT_y,[0.5 0.5 0.5], 'FaceAlpha',0.4,'LineStyle','none');

x=1:12000;
 
y=[];
 for i=1:length(Result.centroid(1,:))
     if i==1 && isnan(Result.centroid(1,i))
          Result.centroid(1,i)= Result.centroid(1,i+1);
     elseif i==length(Result.centroid(1,:)) && isnan(Result.centroid(1,i))
           Result.centroid(1,i)= Result.centroid(1,i-1);
          elseif isnan(Result.centroid(1,i))
                Result.centroid(1,i) = (Result.centroid(1,i-1)+Result.centroid(1,i+1))/2;  
     end 
 end

 
 for i=1:60
     if Result.CS_Position(i)==1
         y = [y,Result.centroid(1,300*(i-1)+51:300*(i-1)+250)];
     else
          p = Result.ROIPosition(3)-Result.centroid(1,300*(i-1)+51:300*(i-1)+250);
         y=[y,p];
     end
     
 end
     
         
         
         
y = y/Result.ROIPosition(3)* 55;

scatter(x,y,3,'k','filled');
hold on
set(gca,'XTick',[1500,6000,10500]);
set(gca,'XTicklabel',{'Baseline','Training','Test'});
ylabel('Position(mm)');
axis([0 12000 0 55])


for i=1:length(Result.US.us_right)
   F= fix(Result.US.us_right(i)/300);
   M=mod(Result.US.us_right(i),300);
   x=210*F+M-20;
   y= 53 *ones(1,length(x));
  scatter(x,y,3,'b','filled');
end

for i=1:length(Result.US.us_left)
   F= fix(Result.US.us_left(i)/300);
   M=mod(Result.US.us_left(i),300);
   x=200*F+M-50;
   y=53*ones(1,length(x));
   scatter(x,y,3,'b','filled');
end