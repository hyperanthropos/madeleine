function [ ] = presentation( SESSION_IN, SAVE_FILE_IN, SETTINGS_IN )
%% code to present the experiment
% this code is used for behavioral experiment 3(!)
% dependencies: stimuli.m, mean_variance.m, draw_stims.m
% written for Psychtoolbox (Version 3.0.13 - Build date: Mar 19 2016)
% input: SESSION, SAVE_FILE, SETTINGS

% USER MANUAL
% this function creates stimuli via stimuli.mat ("stim_mat") presents it to
% the subject via draw_stims.m and records the repsonse. results are
% collected in the "logrec" variable, which gets saved in wd/logfiles and
% is ordered like this:

% LINE 01 - trial number
% LINE 02 - trial presentation time
% LINE 03 - reaction time

% LINE 04 - choice: 1 = risky option; 2 = ambiguous option;
% LINE 05 - [not applicable]
% LINE 06 - choice: 1 = left, 2 = right
% LINE 07 - [not applicable]
% LINE 08 - [not applicable]
% LINE 09 - position of risky (non ambiguous) offer: 1 = left, 2 = right

% LINE 10 - probability of high amount
% LINE 11 - probability of low amount
% LINE 12 - risky amount high
% LINE 13 - risky amount low
% LINE 14 - ambiguous amount high
% LINE 15 - ambiguous amount low
% LINE 16 - [not applicable]

% LINE 17 - stimulus number (sorted)
% LINE 18 - session 1 or 2 (number of repeat of the same variation of stimuli)
% LINE 19 - risk variance level (1-15; low to high variance)
% LINE 20 - ambiguity variance level (1-15; low to high variance)
% LINE 21 - [not applicable]
% LINE 22 - expected value level (1-6; low to high expected value)
% LINE 23 - expected value of probabilistic offers

% stimuli.m has more information about the stimuli created
% (matching, diagnostics, ...)
% draw_stims.m features additional settings for visual presentation
% (colors, visual control variants, ...)

%% SET PARAMETERS

SESSION = SESSION_IN;               % which session (1 or 2) or 0 for training
SAVE_FILE = SAVE_FILE_IN;           % where to save

% FURTHER SETTINGS

SETTINGS.DEBUG_MODE = 0;                            % display trials in command window and some diagnotcis
SETTINGS.WINDOW_MODE = 0;                           % set full screen or window for testing
SETTINGS.TEST_MODE = SETTINGS_IN.TEST_FLAG;         % show reduced number of trials (training number) for each session

SETTINGS.LINUX_MODE = SETTINGS_IN.LINUX_MODE;       % set button mapping for linux or windows system

SETTINGS.SCREEN_NR = max(Screen('Screens'));        % set screen to use
                                                    % run Screen('Screens') to check what is available on your machine
SETTINGS.SCREEN_RES = [1280 1024];                  % set screen resolution (centered according to this input)
                                                    % test with Screen('Resolution', SETTINGS.SCREEN_NR)

% TIMING SETTINGS
TIMING.outcome = .5;        % time to shwo selected choice
TIMING.isi = .3;            % time to wait before starting next trial with preparatory fixation cross

% create zero timing for test mode                            
if SETTINGS.TEST_MODE == 1;
    TIMING.outcome = 0;         % time to shwo the actual outcome (resolved probabilities or control)
    TIMING.isi = .0;            % time to wait before starting next trial with preparatory fixation cross
end

% CHECK IF THE CORRECT PRESENTATION FUNCTION IS CALLED
% this function should only be called for experiment 2
if SETTINGS_IN.EXP_NUMBER ~= 3
    error('it seems wrapper and presentation version are different - please check that the correct files are in your matlab search path!');
end
    
%% CREATE STIMULI MATRIX

% current design: 12 steps of variation = 432 trials
STIMS.diagnostic_graphs = 0;
STIMS.session = SESSION;

% create matrix
[stim_mat, stim_nr] = stimuli(STIMS.diagnostic_graphs);

% create alternative trials for training
if SESSION == 0;
    [stim_mat] = stimuli(STIMS.diagnostic_graphs);
    stim_nr = 4;
    stim_mat = stim_mat(:,1:stim_nr);
    % create a small modification so that training stimuli are different from experimental ones
    stim_mat(11:12,:) = stim_mat(11:12,:)*( 1+(rand(1)/2.5-.2) ); % +/- up to 20%
end

% display time calulations
if STIMS.diagnostic_graphs == 1;
    reaction_time = 5;
    disp([ num2str(stim_nr) ' trials will be presented, taking approximately ' ...
        num2str( (reaction_time + TIMING.outcome + TIMING.isi)*stim_nr/60 ) ' minutes.' ]);
end

% prepare and preallocate log
logrec = NaN(23,stim_nr);

%% PREPARE PRESENTATION AND PSYCHTOOLBOX
% help for PTB Screen commands can be displayed with "Screen [command]?" 
% help with keycodes with KbName('KeyNames') and affiliates

% set used keys
if SETTINGS.LINUX_MODE == 1;
    rightkey = 115; leftkey = 114;
else
    rightkey = 39; leftkey = 37;
end

% supress warnings to see diagnostic output of stimuli
% you can run "ScreenTest" to check the current machine
warning('PTB warings are currently suppressed');
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'VisualDebugLevel', 0);

% open a screen to start presentation (can be closed with "sca" command)
if SETTINGS.WINDOW_MODE == 1;
    window = Screen('OpenWindow', SETTINGS.SCREEN_NR, [], [0 0 SETTINGS.SCREEN_RES]);
else
    window = Screen('OpenWindow', SETTINGS.SCREEN_NR); % open screen
    HideCursor;  % and hide cursor
end

% set font and size
Screen('TextFont', window, 'Calibri');
Screen('TextSize', window, 36);

% set origion to middle of the screen
Screen('glTranslate', window, SETTINGS.SCREEN_RES(1)/2, SETTINGS.SCREEN_RES(2)/2, 0);

% set background color
background_color = ones(1,3)*230;
Screen(window, 'FillRect', background_color);
Screen(window, 'Flip');
clear background_color;

% launch a start screen (setting screen back to default to draw text and later back to origin again *)
% * this  double transformation is necessary for compatibility with different PTB versions
Screen('glTranslate', window, -SETTINGS.SCREEN_RES(1)/2, -SETTINGS.SCREEN_RES(2)/2, 0);
if SESSION == 2;
    offset = Screen(window, 'TextBounds', 'SESSION 2 - PRESS "G" TO START')/2;
    Screen(window, 'DrawText', 'SESSION 2 - PRESS "G" TO START', SETTINGS.SCREEN_RES(1)/2-offset(3), SETTINGS.SCREEN_RES(2)/2-offset(4));
else
    offset = Screen(window, 'TextBounds', 'PLEASE WAIT...')/2;
    Screen(window, 'DrawText', 'PLEASE WAIT...', SETTINGS.SCREEN_RES(1)/2-offset(3), SETTINGS.SCREEN_RES(2)/2-offset(4));
end
Screen(window, 'Flip');
Screen('glTranslate', window, SETTINGS.SCREEN_RES(1)/2, SETTINGS.SCREEN_RES(2)/2, 0);
clear offset;

% wait to start experiment
if SESSION == 0;
    disp('press a button to continue...');
    pause;
else
    switch SESSION
        case 1
            % WAIT TOGETHER FOR SESSION 1 (press F)
            fprintf('\nthank you, the training is now finished. please have a short break.');
            if SETTINGS.LINUX_MODE == 1; % set key to 'F'
                continue_key = 42;
            else
                continue_key = 70;
            end
        case 2
            % WAIT TOGETHER FOR SESSION 2 (press G)
            fprintf('\nthank you, half of the experiment is now finished. please have a short break.');
            if SETTINGS.LINUX_MODE == 1; % set key to 'G'
                continue_key = 43;
            else
                continue_key= 71;
            end
    end
    press = 0;
    while press == 0;
        [~, ~, kb_keycode] = KbCheck;
        if find(kb_keycode)==continue_key;
            press = 1;
        end
    end
    clear continue_key kb_keycode;
end

%% PRESENT STIMULI

% start timer
start_time = GetSecs;

% loop over all trials
for i = 1:stim_nr;
  
    %%% WRITE LOG %%%
    logrec(1,i) = i; % trial number
    %%% WRITE LOG %%%
      
    % sort elements that will be used for each trial
    ev_level = stim_mat(5,i);
    expected_value = stim_mat(17,i);
    probablity = stim_mat(10,i);
    risk_low = stim_mat(11,i);
    risk_high = stim_mat(12,i);
    ambiguity_low = stim_mat(13,i);
    ambiguity_high = stim_mat(14,i);
    response = 0; % first draw stimuli without response
    
    % recolor the fixaton cross shortly befor presenting a new stimulus
    Screen('DrawLine', window, [0 128 0], -10, 0, 10, 0, 5);
    Screen('DrawLine', window, [0 128 0], 0, -10, 0, 10, 5);
    Screen(window, 'Flip');
    
    % select what to draw
    if stim_mat(21,i) == 1;
        position = 1; % risky offer left
        if SETTINGS.DEBUG_MODE == 1;
            disp([  num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) ' CHF' ...
                '| OR |' num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) ' CHF']);
        end
    elseif stim_mat(21,i) == 2;
        position = 2; % risky offer right
        if SETTINGS.DEBUG_MODE == 1;
            disp([  num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) ' CHF' ...
                '| OR |' num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) ' CHF'  ]);
        end
    end
    
    %%% WRITE LOG %%%
    logrec(9,i) = position; % position of risky offer: 1 = left, 2 = right

    logrec(2,i) = GetSecs-start_time; % time of presention of trial
    ref_time = GetSecs; % get time to meassure response
    %%% WRITE LOG %%%
    
    %%% USE FUNCTION TO DRAW THE STIMULI
    
    % select function to draw stimuli
    draw_function = @draw_stims;
    
    % (1) DRAW THE STIMULUS (before response)
    draw_function(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, position, response);
    
    % view logfile debug info
    if SETTINGS.DEBUG_MODE == 1;
        disp(' ');
        disp([ 'position of risky offer: 1 = left, 2 = right: ' num2str(logrec(9,i)) ]);
        disp(' ');
        disp([ 'time: ' num2str(logrec(2,i)) ]);
        if i > 1;
            disp([ 'total stimulus lenght (last): ' num2str(logrec(2,i)-logrec(2,i-1)) ]);
            disp([ 'total stimulus lenght (last) without RT: ' num2str(logrec(2,i)-logrec(2,i-1)-logrec(3,i-1)) ]);
        end
    end
    
    % (X) GET THE RESPONSE
    while response == 0;                    % wait for respsonse
        [~, ~, kb_keycode] = KbCheck;
        
        if find(kb_keycode)==leftkey        % --- left / LINUX: 114 / WIN: 37
            response = 1;
            
            %%% WRITE LOG %%%
            logrec(3,i) = GetSecs-ref_time; % reaction time
            logrec(6,i) = response; % response (1 = left, 2 = right);
            
            if position == 1; % risky offer left
                logrec(4,i) = 1; % choice was risky option
            elseif position == 2; % risky offer right
                logrec(4,i) = 2; % choice was ambiguous option
            end
            %%% WRITE LOG %%%
     
        elseif find(kb_keycode)==rightkey   % --- right / LINUX: 115 / WIN: 39
            response = 2;
            
            %%% WRITE LOG %%%
            logrec(3,i) = GetSecs-ref_time; % reaction time
            logrec(6,i) = response; % response (1 = left, 2 = right);
            
            if position == 1; % risky offer left
                logrec(4,i) = 2; % choice ambiguous option
            elseif position == 2; % risky offer right
                logrec(4,i) = 1; % choice was risky option
            end
            %%% WRITE LOG %%%
            
        end
    end
   
    % (2) DRAW THE RESPONSE
    draw_function(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, position, response);
      
    % (X) WAIT AND FLIP BACK TO PRESENTATION CROSS
    WaitSecs(TIMING.outcome); % present final choice
    
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);   
    Screen(window, 'Flip');

    %%% END OF STIMULI PRESENTATION
    
    % log everything relevant that happened this trial
    % (this is done independend of stim_mat for security reason (can be validated later on))
    logrec(10,i) = probablity;          % probability of high amount
    logrec(11,i) = 1 - probablity;      % probability of low amount
    logrec(12,i) = risk_high;           % risky amount high
    logrec(13,i) = risk_low;            % risky amount low
    logrec(14,i) = ambiguity_high;      % ambiguous amount high
    logrec(15,i) = ambiguity_low;       % ambiguous amount low
    logrec(22,i) = ev_level;            % expected value level
    logrec(23,i) = expected_value;      % expected value

    % view logfile debug info
    if SETTINGS.DEBUG_MODE == 1;
        disp(' ');
        disp([ 'RT: ' num2str(logrec(3,i)) ]);
        disp([ 'choice: 1 = risky; 2 = ambiguous: ' num2str(logrec(4,i)) ]);
        disp(' '); disp(' --- --- --- --- --- --- ---- '); disp(' ');
    end
    
    % clear all used variables for security
    clear probablity risk_low risk_high ambiguity_low ambiguity_high risk position response kb_keycode;
    
    % show a "half time screen" allowing participants to make a short break
    if i == round(stim_nr/2)
        % (setting screen back to default to draw text and later back to origin again *)
        % * this  double transformation is necessary for compatibility with different PTB versions
        Screen('glTranslate', window, -SETTINGS.SCREEN_RES(1)/2, -SETTINGS.SCREEN_RES(2)/2, 0);
        offset = Screen(window, 'TextBounds', 'HALF TIME BREAK - PRESS ENTER TO CONTINUE')/2;
        Screen(window, 'DrawText', 'HALF TIME BREAK - PRESS ENTER TO CONTINUE', SETTINGS.SCREEN_RES(1)/2-offset(3), SETTINGS.SCREEN_RES(2)/2-offset(4));
        Screen(window, 'Flip');
        Screen('glTranslate', window, SETTINGS.SCREEN_RES(1)/2, SETTINGS.SCREEN_RES(2)/2, 0);
        clear offset;
        WaitSecs(3);
        disp('press a button to continue...');
        pause; 
    end
    
    % wait before next trial
    WaitSecs(TIMING.isi);
    
end
clear i leftkey rightkey;

% close the screen
Screen('CloseAll');

%% SAVE RESULTS

% add relevant info from stim_mat to logfile...
logrec(17,:) = stim_mat(3,:);        % stimulus number
logrec(19,:) = stim_mat(6,:);        % risk variance level
logrec(20,:) = stim_mat(7,:);        % ambiguity variance level

% add session number to logrec
logrec(18,:) = ones(1,stim_nr)*SESSION;

% ...derandomize...
sorted_stim_mat = sortrows(stim_mat', 3)'; %#ok<NASGU> (this is created to be included in the save file)
sorted_logrec = sortrows(logrec', 17)'; %#ok<NASGU> (this is created to be included in the save file)

% ...and save
disp(' '); disp('saving data...');
save(SAVE_FILE);

%% end function
end