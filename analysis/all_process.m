

for i=1:length(Result.centroid(1,:))
    if i==1 && isnan(Result.centroid(1,i))
        Result.centroid(1,i)= Result.centroid(1,i+1);
    elseif i==length(Result.centroid(1,:)) && isnan(Result.centroid(1,i))
        Result.centroid(1,i)= Result.centroid(1,i-1);
    elseif isnan(Result.centroid(1,i))
        Result.centroid(1,i) = (Result.centroid(1,i-1)+Result.centroid(1,i+1))/2;
        
    end
end
y = Result.centroid(1,:)/Result.ROIPosition(3)* 70;

figure;
for i = 1:6
    plot((i-1)*200+1:i*200,y((i-1)*200+1:i*200),'k','LineWidth',1);
    hold on
end


plot(1200:7200,y(1200:7200),'k','LineWidth',1);
for i = 37:42
    plot((i-1)*200+1:i*200,y((i-1)*200+1:i*200),'k','LineWidth',1);
    hold on
end

for i=1:6
    x=[(i-1)*200+71 200*(i-1)+130 200*(i-1)+130 (i-1)*200+71];
    if Result.CS_Position(i)==1
        y=[0 0 35  35];
    else
        y=[35 35 70 70];
    end
    fill(x,y,[0.85 0.33 0.1], 'FaceAlpha',0.4,'LineStyle','none');
end

for i=7:36%18
    x=[(i-1)*200+71 200*(i-1)+130 200*(i-1)+130 (i-1)*200+71];
    if Result.CS_Position(i)==1
        y=[0 0 35 35];
    else
        y=[35 35 70 70];
    end
    fill(x,y,'r', 'FaceAlpha',0.4,'LineStyle','none');
end

for i=37:42%19:24
    x=[(i-1)*200+71 200*(i-1)+130 200*(i-1)+130 (i-1)*200+71];
    if Result.CS_Position(i)==1
        y=[0 0 35  35];
    else
        y=[35 35 70 70];
    end
    fill(x,y,[0.85 0.33 0.1], 'FaceAlpha',0.4,'LineStyle','none');
end

hold on
set(gca,'XTick',[600 4200 7800]);
set(gca,'XTicklabel',{'Baseline','Acquisition','Test'});
ylabel('Position(mm)');
