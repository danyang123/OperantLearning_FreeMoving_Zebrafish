figure;
BT_x{1}=[0 415 415 0];
BT_y=[0 0 55 55];
BT_x{2}=[2525 2940 2940 2525];
fill(BT_x{1},BT_y,[0.5 0.5 0.5], 'FaceAlpha',0.4,'LineStyle','none');
hold on
fill(BT_x{2},BT_y,[0.5 0.5 0.5], 'FaceAlpha',0.4,'LineStyle','none');


x=1:2940;
 
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
 
for i=1:42
  y = [y,Result.centroid(1,(i-1)*200+71:200*(i-1)+130),nan,nan,nan,nan,nan,nan,nan,nan,nan,nan];
end
y = y/Result.ROIPosition(3)* 55;

plot(x,y,'k','LineWidth',1);
hold on

for i=1:42
       x=[(i-1)*70+1 70*(i-1)+60 70*(i-1)+60 (i-1)*70+1]; 
       if Result.CS_Position(i)==1
           y=[0 0 27.5 27.5];
            if Result.centroid(1,200*(i-1)+130)<=(Result.ROIPosition(3)/2)
               color = 'r';
           else
               color = [0,0.45,0.74];
           end
       else
           y=[27.5 27.5 55 55];
            if Result.centroid(1,200*(i-1)+130)>=(Result.ROIPosition(3)/2)
               color = 'r';
           else
               color = [0,0.45,0.74];
           end
       end
      
      fill(x,y,color, 'FaceAlpha',0.4,'LineStyle','none');
end

hold on
set(gca,'XTick',[210,1470,2730]);
set(gca,'XTicklabel',{'Baseline','Training','Test'});
ylabel('Position(mm)');
hold on
axis([0 2940 0 55]) 
for i=1:length(Result.US.us_right)
   F= fix(Result.US.us_right(i)/200);
   M=mod(Result.US.us_right(i),200);
   x=70*F+M-70;
   y= 53 *ones(1,length(x));
  scatter(x,y,3,'b','filled');
end

for i=1:length(Result.US.us_left)
   F= fix(Result.US.us_left(i)/200);
   M=mod(Result.US.us_left(i),200);
   x=70*F+M-70;
   y=2*ones(1,length(x));
   scatter(x,y,3,'b','filled');
end

