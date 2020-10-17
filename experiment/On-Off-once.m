for  t = 101:148
       tic
       ImageProcessing();
       if US==2 && t>131 && us_on==0
           if  CS_Flag==1 && centroid(1,m)< xDivide
               CMD(2) = PB6;
               fwrite(device, CMD, 'uint16');
               us_left=[us_left,m];
               us_on=1;
           elseif CS_Flag==2 && centroid(1,m)>xDivide
               CMD(2) = PB7;
               us_right=[us_right,m];
               fwrite(device, CMD, 'uint16');
               us_on=1;
           end
       end
       if  (t==148 || (CS_Flag==1 && centroid(1,m)> xDivide) ||( CS_Flag==2 && centroid(1,m)<xDivide) )&& us_on==1  && US==2
           CMD(2) = 0;
           fwrite(device, CMD, 'uint16');
           us_on=0;
           us_end=[us_end,m];
       end
       pause_T =fs_frame-toc;
       if pause_T<0
           delay=[m;pause_T];
           time_delay=[time_delay,delay];
       end
       pause(pause_T);
   end