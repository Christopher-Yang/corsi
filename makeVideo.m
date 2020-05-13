subj = 3;
day = 'day10';
hand = 'bimanual';
trial = 13;
if strcmp(day,'day2')
    dayName = '2-day';
elseif strcmp(day,'day5')
    dayName = '5-day';
elseif strcmp(day,'day10')
    dayName = '10-day';
end
handName = [upper(hand(1)) hand(2:end)];

targets = [.52 .72 .55 .59 .53 .6 .65 .67 .69
           .32 .22 .27 .18 .21 .3 .26 .20 .34];

dat = data.(day){subj}.(hand);
curs.x = dat.trajFilt{trial}(:,1);
curs.y = dat.trajFilt{trial}(:,2);
press = dat.press{trial};
buttonsPressed = dat.buttonsPressed{trial};
answer = dat.answer{trial};
Nanswer = length(answer);
% Lhand.x = dat(:,3);
% Lhand.y = dat(:,4);
% Rhand.x = dat(:,5);
% Rhand.y = dat(:,6);

Nsamples = size(curs.x,1);

figure(1); clf; hold on
scatter(targets(1,:),targets(2,:),3000,'k','filled','MarkerFaceAlpha',0.4)
plot(curs.x,curs.y)
% plot(Lhand.x,Lhand.y)
% plot(Rhand.x,Rhand.y)
axis([0.47 0.77 0.13 0.43])
axis square
%%
fhandle = figure(1); clf; hold on
    set(fhandle, 'Position', [50, 50, 800, 800]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white
    
v = VideoWriter('test.avi','Motion JPEG AVI');
v.FrameRate = 130/4;
open(v);
figure(1); clf; hold on

c1 = [105 105 105]./255;
c2 = [255 255 51]./255;
c3 = [135 206 235]./255;
count = 1;
timer = (1.5+(1:Nanswer)).*130.004;
endTime = max(find(dat.press{trial}==1));

for t=1:4:Nsamples
    cla
    axis off
    text(0.5,0.46,['Subject ' num2str(subj) newline dayName newline handName newline 'Trial ' num2str(trial)])  
    plot(targets(1,:),targets(2,:),'ko','Color',c1,'LineWidth',2,'MarkerSize',50,'MarkerFaceColor',c1,'MarkerEdgeColor','k')
    if t < (Nanswer+1.5)*130.004
        text(0.55,0.13,['There will be ' num2str(Nanswer) ' targets'],'FontSize',16);
        plot(0.6,0.4,'ko','Color',c3,'MarkerSize',35,'MarkerFaceColor',c3)
        if t>=timer(count)-130.004 && t<timer(count)-(0.3*130.004)
            plot(targets(1,answer(count)),targets(2,answer(count)),'ko','Color',c2,'LineWidth',2,'MarkerSize',50,'MarkerFaceColor',c2,'MarkerEdgeColor','k')
        elseif t>=timer(count)
            count = count+1;
        end
    elseif t <= endTime
        if press(t) == 1
            plot(targets(1,buttonsPressed(t)+1),targets(2,buttonsPressed(t)+1),'ko','Color',c2,'LineWidth',2,'MarkerSize',50,'MarkerFaceColor',c2,'MarkerEdgeColor','k')
        end
    else
        plot(0.6,0.4,'ko','Color',c3,'MarkerSize',35,'MarkerFaceColor',c3)
    end
    plot(curs.x(1:t),curs.y(1:t),'r')
    plot(curs.x(t),curs.y(t),'ko','markersize',8,'markerfacecolor',[1 0 0],'linewidth',1.5)
%     plot(Lhand.x(1:t),Lhand.y(1:t),'b')
%     plot(Rhand.x(1:t),Rhand.y(1:t),'g')
%     plot(Lhand.x(t),Lhand.y(t),'ko','markersize',8,'markerfacecolor',[0 0 1],'linewidth',1.5)
%     plot(Rhand.x(t),Rhand.y(t),'ko','markersize',8,'markerfacecolor',[0 1 0],'linewidth',1.5)
    axis([0.42 0.82 0.08 0.48])
    
    frame = getframe;
    writeVideo(v,frame);
end
close(v);