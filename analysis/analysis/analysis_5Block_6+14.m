figure;
BT_x{1}=[0 3145 3145 0];
BT_y=[0 0 55 55];
BT_x{2}=[9455 12600 12600 9455];
fill(BT_x{1},BT_y,[0.5 0.5 0.5], 'FaceAlpha',0.4,'LineStyle','none');
hold on
fill(BT_x{2},BT_y,[0.5 0.5 0.5], 'FaceAlpha',0.4,'LineStyle','none');


x=1:12600;
 
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
  y = [y,Result.centroid(1,300*(i-1)+51:300*(i-1)+250),nan,nan,nan,nan,nan,nan,nan,nan,nan,nan];
end
y = y/Result.ROIPosition(3)* 55;

plot(x,y,'k','LineWidth',1);
hold on

for i=1:60
       x=[(i-1)*210+1 210*(i-1)+200 210*(i-1)+200 (i-1)*210+1]; 
       if Result.CS_Position(i)==1
           y=[0 0 27.5 27.5];
           if Result.centroid(1,300*(i-1)+250)<=(Result.ROIPosition(3)/2)
               color = 'r';
           else
               color = [0,0.45,0.74];
           end
       else
           y=[27.5 27.5 55 55];
           if Result.centroid(1,300*(i-1)+250)>=(Result.ROIPosition(3)/2)
               color = 'r';
           else
               color = [0,0.45,0.74];
           end
       end
      
      fill(x,y,color, 'FaceAlpha',0.4,'LineStyle','none');
end

hold on
set(gca,'XTick',[1575,6300,11030]);
set(gca,'XTicklabel',{'Baseline','Training','Test'});
ylabel('Position(mm)');
hold on
axis([0 12600 0 55]) 


for i=1:length(Result.US.us_right)
   F= fix(Result.US.us_right(i)/300);
   M=mod(Result.US.us_right(i),300);
   x(i)=210*F+M-60;
    y= 53 *ones(1,length(x)); 
    scatter(x,y,3,'b','filled');
end

for i=1:length(Result.US.us_left)
   F= fix(Result.US.us_left(i)/300);
   M=mod(Result.US.us_left(i),300);
   x=210*F+M-60;
   y=2*ones(1,length(x));
   scatter(x,y,3,'b','filled');
end

