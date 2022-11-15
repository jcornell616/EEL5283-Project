function [displc_abs, displc_rel] = calcDisplacement(Data)
%{ legacy code
% Data = Data-mean(Data);
% y = sum(abs(Data), 2);
% indxx = find(abs(diff(y))>0,1);
% displc = y(indxx+1:end);
%yy = sum(abs(Data), 2);

%yy = yy-mean(yy);
%keyboard;
%indxx = find(abs(diff(yy))>-1,1); %originally >0; if set to -1, then calculate displacement for all points instead of extracting only points with movement
%displc = yy(indxx+1:end);
%displc = yy;
%}
x = Data(:,1)-Data(1,1);
y = Data(:,2)-Data(1,2);
z = Data(:,3)-Data(1,3);
displc_abs = sqrt(x.^2 + y.^2 + z.^2);
%displc_abs =  displc_abs - mean(displc_abs);
displc(1) = 0;
for i = 2:length(displc_abs)
    displc (i)= displc_abs(i) -displc_abs(i-1);
end
%figure, plot(x,'r'), hold on, plot(y,'g'), hold on, plot(z,'b'), hold on,...
%    plot(displc_abs,'m'),hold on, plot(displc,'c');
%keyboard;
displc_rel = displc;
end