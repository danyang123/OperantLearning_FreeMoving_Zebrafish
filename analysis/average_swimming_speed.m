for i=1:length(Result.centroid(1,:))
     if i==1 && isnan(Result.centroid(1,i))
          Result.centroid(1,i)= Result.centroid(1,i+1);
     elseif i==length(Result.centroid(1,:)) && isnan(Result.centroid(1,i))
           Result.centroid(1,i)= Result.centroid(1,i-1);
          elseif isnan(Result.centroid(1,i))
         Result.centroid(1,i) = (Result.centroid(1,i-1)+Result.centroid(1,i+1))/2;
     
     end 
 end

y=zeros(1,30); 
for i=7:36
   
  p = [y,Result.centroid(1,(i-1)*200+71:200*(i-1)+130)];
  y(i-6)=sum(p)/200/Result.POIPosition(3)*70;
end
figure;
plot(y)
