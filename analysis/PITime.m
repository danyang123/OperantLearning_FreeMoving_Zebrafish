%% PI_Time =  PITime(Result)
PI_Time= zeros(0,60);
for i=1:60
    m=0;
    p=[];
    b=[];
    positive_num=[];
    if Result.CS_Position(i)==1
        p = Result.centroid(1,300*(i-1)+51:300*(i-1)+250);
    else
        p = Result.ROIPosition(3)-Result.centroid(1,300*(i-1)+51:300*(i-1)+250);
    end
    for t=1:length(p)
        if isnan(p(t))
            m=m+1;
            b(m)=t;
        end
    end
    if m>0
        p(b)=[];
    end
    positive_num = (p>(Result.ROIPosition(3)/2));
    PI_Time(i)=length(find( positive_num==1))/length( positive_num);
end
end
%% scatter ¼¸¸ö½×¶Î
Baseline = mean(PI_Time(1:15));
for i=1:5
    Training(i)=mean(PI_Time(15+6*(i-1)+1:15+6*(i-1)+6));
end
Test = mean(PI_Time(46:60));
x1=[3 13];
x2=[6 7 8 9 10 ];
y=[Baseline,Test];
scatter(x1,y);
hold on
scatter(x2,Training);
%% Öù×´Í¼ËãÏÔÖøÐÔ
figure;
x=[3 5];
y=[mean(PI_Time(1:15)),mean(PI_Time(46:60))];
Baseline_sem=std(PI_Time(1:15),0)/sqrt(15);
Test_sem=std(PI_Time(46:60),0)/sqrt(15);
err=[Baseline_sem,Test_sem]; 
hold on
 errorbar(x,y,err,'.','Color',[0 0 0]);
 bar(x(1),y(1),0.5,'FaceColor',[1 1 1]);
 bar(x(2),y(2),0.5,'FaceColor',[0 0 0]);
axis([1 7 0 1]) 
set(gca,'XTick',[3 5]);
set(gca,'XTicklabel',{'Baseline','Test'});
ylabel('Position Index');
[h,p]=ttest(PI_Time(1:15),PI_Time(46:60));
line([3,5],[0.95,0.95],'Color',[0,0,0]);
 str = sprintf('**',p);
  text(4,0.95,str,'FontSize',14);