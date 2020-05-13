clear all
load P2Pdat

delayStep = 20;
space = 6;

folder = 'Data/denovo_2day/';
subj_name2 = {'subj1','subj2','subj3','subj4','subj5','subj6','subj7','subj8','subj9','subj10','subj11','subj12','subj13','subj14'};
data.day2 = loadData(folder,subj_name2,delayStep);

folder = 'Data/denovo_5day/';
subj_name5 = {'subj13','subj18','subj19','subj21','subj22','subj23','subj24','subj25','subj26','subj27','subj28','subj29'};
data.day5 = loadData(folder,subj_name5,delayStep);

folder = 'Data/denovo_10day/';
subj_name10 = {'subj1','subj2','subj3','subj4','subj5'};
data.day10 = loadData(folder,subj_name10,delayStep);

colors = [0 0 0
          128 128 128
          255 69 0
          255 165 0]./255;
Nsubj = [length(subj_name2),length(subj_name5),length(subj_name10)];
groups = {'day2','day5','day10'};
hands = {'unimanual','bimanual'};
disp('Done')

function data = loadData(folder, subj_name, delayStep)

disp('Analyzing...')
hands = {'unimanual','bimanual'};

% "increment" is a matrix that increases the numbers in tOrder by 1. This
% translates the 0 indexing of "tOrder" (C++) to 1 indexing (MATLAB).
% Also, this eliminates the ambiguities of ending 0's in tOrder
increment = ones(30,4); 
for j = 1:5
    z = ones(30,1);
    z(1:5*j) = 0;
    increment = [increment z];
end

% target positions
targets = [.52 .72 .55 .59 .53 .6 .65 .67 .69
           .32 .22 .27 .18 .21 .3 .26 .20 .34]; 

for l = 1:length(subj_name) % loop over subjects
    disp(['    ',subj_name{l}])
    for k = 1:2 % loop over unimanual/bimanual
        error = [];
        path = [folder subj_name{l} '/' hands{k} '/']; % set data path
        fnames = dir(path); % get filenames in path
        fnames = fnames(not([fnames.isdir])); % get rid of directories in fnames
        
        % set variables for data analysis
        tOrder = dlmread([path 'tOrder.txt']); % read in tOrder
        tOrder = tOrder+increment; % increment tOrder
        Ncorrect = 0; % count number of trials participant got correct
        Nbad = 0; % count number of trials where hardware screwed up data collection
        Ntrials = size(fnames,1)-1; % number of trials
        blockSpan = 0;
        
        for j = 1:Ntrials % loop over trials
            [releaseTime,pressTime,initDir,targRel,targAngle,initTime,pathLength] = deal([]);
            d = dlmread([path fnames(j).name],' ',6,0); % read data into d
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % analyze block tapping accuracy
            
            % get button press data as input
            input = d(:,12);
            
            % identify correct answers
            answer = tOrder(j,:); % extract the correct answer for trial j
            answer(answer==0) = []; % get rid of 0's when sequence length<9
            
            % identify the blocks which participants tapped
            guess = input(1); % initialize guess
            for i = 2:length(input) % loop over all data samples
                if input(i) ~= input(i-1)
                    guess = [guess; input(i)]; % only add samples which are different from preceding sample
                end
            end
            guess = guess(guess~=-1)'+1; % gets rid of data when there's no button presses
            
            % compare guess and answer
            if length(guess) ~= length(answer) % count trials where hardware screwed up
                Nbad = Nbad + 1;
            elseif sum(guess==answer) == length(answer) % count trials where guess matches answer
                Ncorrect = Ncorrect + 1;
                blockSpan = length(answer);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % analyze kinematics during block tapping
            
            % identify button presses and releases
            press = input~=-1; % all times when the button is pressed
            for i = 2:length(press)
                if press(i) == 0 && press(i-1) == 1 % first moment when button was released
                    releaseTime = [releaseTime i];
                elseif press(i) == 1 && press(i-1) == 0 % first moment when button was pressed
                    pressTime = [pressTime i];
                end
            end 

            time = d(:,11)-d(1,11); % time vector
            trajRaw = d(:,7:8); % raw trajectory
            trajFilt = sgolayfilt(trajRaw,3,11); % savitzky-golay filtered trajectories
            vel = diff(trajFilt)./diff(time/1000); % compute velocity of movements
            
            if length(releaseTime) ~= length(answer) % skip analysis for trials where hardware screwed up
                initDir = NaN;
                targAngle = NaN;
                analysisTime = NaN;
                movementTime = NaN;
                pathLength = NaN;
            else
                % identify movement initiation time
                for i = 1:length(releaseTime)-1
                    found = 0; % flag for breaking while loop
                    idx = 1; % increments releaseTime 
                    start = trajFilt(releaseTime(i),:); % begin analysis at releaseTime
                    while found == 0 % i.e., if initiation time hasn't been found...
                        if releaseTime(i)+idx <= size(trajFilt,1) % limit search to length of trajectory
                            next = trajFilt(releaseTime(i)+idx,:); 
                            relative = next-start;
                            distance = sqrt(relative(1)^2 + relative(2)^2); % distance between initial and current position
                            if distance >= 0.005 % break loop if distance is greater than 5 mm
                                initTime = [initTime releaseTime(i)+idx];
                                found = 1;
                            end
                            idx = idx+1;
                        else % make initiation time NaN if search exceeds length of trajectory
                            initTime = [initTime NaN];
                            break
                        end
                    end
                end
                
                analysisTime = initTime+delayStep; % analyzes data "delayStep" after movement initiation
                movementTime = time(pressTime(2:end))-time(initTime); % time between movement initiation and next press
                
                % compute path length between each block tap.
                for i = 1:length(initTime)
                    reach = trajFilt(initTime(i):pressTime(i+1),:);
                    dpath = diff(reach,1);
                    dL = sqrt(sum(dpath.^2,2));
                    pathLength(i) = sum(dL);
                end
                
                % computes variables for measuring reach direction error
                for i = 1:length(analysisTime) 
                    if ~isnan(analysisTime(i))
                        % initial reach direction at analysisTime
                        initDir(i) = atan2(vel(analysisTime(i),2),vel(analysisTime(i),1));
                        
                        % position of next target relative to position at
                        % analysisTime (NOTE: next target is the next
                        % target that is pressed, not the next correct
                        % target)
                        targRel(i,:) = targets(:,guess(i+1))' - trajFilt(analysisTime(i),:);
                        
                        % relative angle of next target
                        targAngle(i) = atan2(targRel(i,2),targRel(i,1));
                    else
                        initDir(i) = NaN;
                        targAngle(i) = NaN;
                    end
                end
                
                error = [error initDir-targAngle]; % initial reach direction error
            end
            
            % store variables from each trial in data
            data{l}.(hands{k}).trajRaw{j} = trajRaw;
            data{l}.(hands{k}).trajFilt{j} = trajFilt;
            data{l}.(hands{k}).vel{j} = vel;
            data{l}.(hands{k}).initDir{j} = initDir;
            data{l}.(hands{k}).targAngle{j} = targAngle;
            data{l}.(hands{k}).press{j} = press;
            data{l}.(hands{k}).analysisTime{j} = analysisTime;
            data{l}.(hands{k}).movementTime{j} = movementTime;
            data{l}.(hands{k}).buttonsPressed{j} = input;
            data{l}.(hands{k}).answer{j} = answer;
            data{l}.(hands{k}).pathLength{j} = pathLength';
        end
        
        % wrap all reach direction errors between (-pi,pi]
        for i = 1:length(error)
            while error(i) > pi
                error(i) = error(i)-2*pi;
            end
            while error(i) <= -pi
                error(i) = error(i)+2*pi;
            end
        end
        
        % save variables from across trials in data
        data{l}.(hands{k}).blockSpan = blockSpan; % sequence length of last correct trial
        data{l}.(hands{k}).totalScore = Ncorrect*blockSpan;
        data{l}.(hands{k}).meanCorrect = Ncorrect/Ntrials;
        data{l}.(hands{k}).systemError = Nbad;
        data{l}.(hands{k}).error = error*180/pi; % convert error from radians to degrees
        data{l}.(hands{k}).std = std(error*180/pi); % standard deviation of error
    end
end
end