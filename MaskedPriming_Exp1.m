%% Masked Priming Lexical Decision
% Letter chunk frequency does not explain morphological masked priming : Affix frequency in masked priming
% De Rosa, M. - May 2017

% Masked priming combined with lexical decision;
% Randomization of items within each single session;
% Present stimuli;
% Collect responses & RTs
% Check for bad ticks in stimuli presentation

%% Start a new session
clear all;
close all;
clc;
opengl hardware; %uses a hardware-accelerated version of OpenGL to render subsequent graphics.
%% Set up materials: global variables; stimuli
global  GlobalExperimentID GlobalSubjectID GlobalRotationID Start stop TempRespTime Handedness


GlobalExperimentID=input('Experiment ID: ', 's');
GlobalSubjectID=input('Subject ID: ', 's');
GlobalRotationID=input('Rotation number: ', 's');
Handedness=input('Handedness: ', 's'); %% Input: S or D
%EscKeyID =KbName('esc');
filename = [char(GlobalExperimentID) 'rotation' char(GlobalRotationID) '.txt'];
% Load the specific rotation
Table = readtable(char(filename), 'Delimiter', ' '); % define the rotation file
mask=repmat('#',1,max(cellfun('length', Table.prime))); % create a mask as long as the longest prime in the session


%% Listen to the response box
%
hdl = CedrusResponseBox('Open', 'COM3'); %open port
boxinfo = CedrusResponseBox('GetDeviceInfo', hdl); %get info from Cedrus
Stat = CedrusResponseBox('FlushEvents', hdl); %get info of button pressed

try
    %% SCREEN
    back_color=0; %black
    text_color=100; %gray. Other option: 140
    TextSize=32;
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'Verbosity', 0);
    win = Screen('openWindow', 2, back_color); %, [100 100 1300 1300]); %[0 0 640 480]);
    Screen('Preference', 'TextRenderer', 1);
    Screen('Preference', 'DefaultFontName','Arial');
    Screen('Preference', 'DefaultFontName');
    Screen('TextStyle',win,0);
    Screen('TextFont',win, 'Monospaced');
    Screen('TextFont',win, 'Arial');
    Screen('TextSize',win, TextSize);
    
    % Prioritize
    PriorityLevel=MaxPriority(win);
    Priority(PriorityLevel);
    
    %Centering
    
    [width, height]=Screen('WindowSize', 2); %get size in pixel of second monitor
    MaxDXpixel=width;
    MaxDYpixel=height;
    shCenter = (MaxDXpixel)/2;
    svCenter = (MaxDYpixel)/2;
    
    %% TIMING: Refresh rates and stimuli duration
    
    MonitorRefresh_hertz=Screen('NominalFrameRate', win); % collect the refresh rate (60HZ)
    % set the duration of each phase
    interstimulis_interval_sec=1.5;
    mask_duration_sec=0.5;
    prime_duration_sec= 0.050;
    target_duration_sec= 1.5;
    lastframe_duration_sec= 0.01;
    
    %to detecti missed refreshes
    DeltaTime=1/MonitorRefresh_hertz;
    Max_DeltaTime_error=DeltaTime/2;
    % multiply the duration in seconds for the refresh rate
    interstimulis_interval_max_frames=fix(interstimulis_interval_sec*MonitorRefresh_hertz);
    mask_max_frames=fix(mask_duration_sec*MonitorRefresh_hertz);
    prime_max_frames=fix(prime_duration_sec*MonitorRefresh_hertz);
    target_max_frames=fix(target_duration_sec*MonitorRefresh_hertz);
    lastframe_duration_sec=fix(target_duration_sec*MonitorRefresh_hertz);
    
    % il +1 nel num dei ticks  serve per il caclolo tel tick dell'ultimo frame
    total_experiment_tick_time=zeros(interstimulis_interval_max_frames+mask_max_frames+prime_max_frames+target_max_frames+1);
    tick_counter=uint32(0);
    
    TimeString=strrep(num2str([ fix(clock()) ]),'    ','_');
    
    %% Randomizing Stimuli
    n_examples = 2;
    n_practice = 12;
    n_warmup = 4;
    n_trialsperblock = 12;
    n_experimental_items = 156;
    beforepause = 80;
    
    Table.target = upper(Table.target);
    MyTrials = table2struct(Table); % Convert into structure
    %Create a temporary copy; otherwise, it will read itself while overwriting, causing repetitions
    MyTrials_temp = MyTrials;
    BlockIntervals = n_examples+n_practice+n_warmup+1:n_trialsperblock:length(MyTrials);
    RandomizedBlock = BlockIntervals(randperm(length(BlockIntervals)));
    
    MyTrials(1:n_examples) = MyTrials_temp(randperm(length(MyTrials_temp(1:n_examples))));
    Training = MyTrials_temp(n_examples+1:n_examples+n_practice);
    MyTrials(n_examples+1:n_examples+n_practice) =  Training(randperm(length(Training)));
    WarmUp = MyTrials_temp(n_examples+n_practice+1:n_examples+n_practice+n_warmup);
    MyTrials(n_examples+n_practice+1:n_examples+n_practice+n_warmup) = WarmUp(randperm(length(WarmUp)));
    
    % Randomizing both blocks and items
    for i=1:length(BlockIntervals)
        Block = MyTrials_temp(BlockIntervals(i):BlockIntervals(i)+n_trialsperblock-1);
        MyTrials(RandomizedBlock(i):RandomizedBlock(i)+n_trialsperblock-1) = Block(randperm(length(Block)));
    end
    
    %% Set the output file
    output_directory='MPF_outputs';
    output_file_name=[output_directory '/outputExperiment' GlobalExperimentID  '_SubjID' GlobalSubjectID  '.txt'];
    fid=fopen(output_file_name,'a');%Global
    fprintf(fid,'\n');
    fprintf(fid,'#SubjectID\tExperimentID\tRotation\tHandedness\tTrialID\tPrime\tTarget\tRT\tResponse\tLexicality\t\n');
    

    %% Instructions
    instructions_Start = {'Premi il tasto centrale per cominciare'};
    instructions_Questions = {'Molto bene. Hai qualche domanda?'};
    instructions_TrueStart = {'Ottimo!\n\nQuando lo sperimentatore ti da'' l''OK,\n\npremi il tasto centrale per iniziare l''esperimento.'};
    if strcmpi(Handedness, 'D')
    instructions_Explanation = {'Benvenuto!\n\nIn questo esperimento vedrai alcune sequenze di lettere.\n\n';
        'Per ogni presentazione dovrai decidere\n\nse la sequenza che vedi e'' una parola realmente esistente in italiano.';
        'In ogni presentazione vedrai una serie di cancelletti \n\ne subito dopo la parola da classificare.';
        'Se la parola esiste \n\npremi il tasto BLU.\n\n\n\nSe la parola non esiste, \n\npremi il tasto VERDE.';
        'Fai attenzione!\n\nCerca di rispondere\n\nin modo RAPIDO e ACCURATO.';
        'Sii piu'' veloce che puoi. \n\nPrendila come una sfida con te stesso.'
        'Quando lo sperimentatore ti da'' l''OK,\n\npremi il tasto centrale per vedere 2 esempi.'};    
    instructions_Training = {'Ricorda!\n\nSe la parola esiste, \n\npremi il tasto BLU.\n\n\n\nSe la parola non esiste in italiano, \n\npremi il tasto VERDE.';
        'Cerca di essere RAPIDO e ACCURATO.';
        'Facciamo un po'' di pratica:\n\nSe sarai troppo lento nel dare la risposta \n\no se darai la risposta sbagliata \n\nlo schermo si colorera'' di rosso.\n\nPremi il tasto centrale per fare alcune prove!'};
     elseif strcmpi(Handedness, 'S')
    instructions_Explanation = {'Benvenuto!\n\nIn questo esperimento vedrai alcune sequenze di lettere.\n\n';
        'Per ogni presentazione dovrai decidere\n\nse la sequenza che vedi e'' una parola realmente esistente in italiano.';
        'In ogni presentazione vedrai una serie di cancelletti \n\ne subito dopo la parola da classificare.';
        'Se la parola esiste \n\npremi il tasto VERDE.\n\n\n\nSe la parola non esiste, \n\npremi il tasto BLU.';
        'Fai attenzione!\n\nCerca di rispondere\n\nin modo RAPIDO e ACCURATO.';
        'Sii piu'' veloce che puoi. \n\nPrendila come una sfida con te stesso.'
        'Quando lo sperimentatore ti da'' l''OK,\n\npremi il tasto centrale per vedere 2 esempi.'};    
    instructions_Training = {'Ricorda!\n\nSe la parola esiste, \n\npremi il tasto VERDE.\n\n\n\nSe la parola non esiste in italiano, \n\npremi il tasto BLU.';
        'Cerca di essere RAPIDO e ACCURATO';
        'Facciamo un po'' di pratica:\n\nSe sarai troppo lento nel dare la risposta \n\no se darai la risposta sbagliata \n\nlo schermo si colorera'' di rosso.\n\nPremi il tasto centrale per fare alcune prove!'};
    end
    %% DISPLAY
    
    %  HideCursor();
    % Start
    Screen('Flip', win);
    WaitSecs(0.5);
    DrawFormattedText(win, instructions_Start{1}, 'center', 'center', text_color);
    Screen('Flip', win);
    CedrusResponseBox('WaitButtonPress', hdl);
    
    for i= 1:length(instructions_Explanation)
        Screen('Flip', win);
        WaitSecs(0.5);
        DrawFormattedText(win, instructions_Explanation{i}, 'center', 'center', text_color);
        Screen('Flip', win);
        CedrusResponseBox('WaitButtonPress', hdl);
    end
    
    %% For loop for presentation of the stimuli
    item = 1;
    while (item<=length(MyTrials))
        WaitSecs(rand*0.2); % Random variation to variate the interstimulus interval
        Start=0;
        stop=0;
        TempRespTime=0;
        tick_counter=0;
        %% Loop for stimuli presentation:
        Screen('FillRect',  win, back_color);
        Screen('Flip', win);
        
        % 	Pause the loop
        if item ==n_examples+n_practice+beforepause
            Screen('Flip', win);
            WaitSecs(0.5);
            DrawFormattedText(win, '- PAUSA ESPERIMENTO - 1 MINUTO -', 'center', 'center', text_color);
            Screen('Flip', win);
            WaitSecs(30);
            Screen('Flip', win);
            WaitSecs(0.5);
            CedrusResponseBox('FlushEvents', hdl);
            DrawFormattedText(win, '- premi il tasto centrale per ricominciare -', 'center', 'center', text_color);
            Screen('Flip', win);
            WaitSecs(0.2);
            CedrusResponseBox('WaitButtonPress', hdl);
            Screen('Flip', win);
            WaitSecs(0.01);
        end
        
        %% Displaying Conditional Instructions
        
        if item==n_examples+1
            for i=1:length(instructions_Questions)
                Screen('Flip', win);
                WaitSecs(0.5);
                DrawFormattedText(win, instructions_Questions{i}, 'center', 'center', text_color);
                Screen('Flip', win);
                CedrusResponseBox('WaitButtonPress', hdl);
            end
            
            for i=1:length(instructions_Training)
                Screen('Flip', win);
                WaitSecs(0.5);
                DrawFormattedText(win, instructions_Training{i}, 'center', 'center', text_color);
                Screen('Flip', win);
                CedrusResponseBox('WaitButtonPress', hdl);
            end
        end
        
        if item==n_examples+n_practice+1
            for i= 1:length(instructions_TrueStart)
                Screen('Flip', win);
                WaitSecs(0.5);
                DrawFormattedText(win, instructions_TrueStart{i}, 'center', 'center', text_color);
                Screen('Flip', win);
                CedrusResponseBox('WaitButtonPress', hdl);
            end
        end
        
        %% Displaying Stimuli
        % Each phase has its own for loop, that allows us to control for the
        % timing in refresh rates
        
        Screen('FillRect', win, back_color);
        Screen('Flip', win);
        %Make sure subject has released key before starting the trial:
        while any(Stat(1,:))
            Stat = CedrusResponseBox('FlushEvents', hdl);
        end
        
        %Interstimulus Interval
        for t1=1:interstimulis_interval_max_frames
            tick_counter=tick_counter+1;
            Screen('Flip', win);
            total_experiment_tick_time(tick_counter);
        end
        
        %Mask
        for t1=1:mask_max_frames
            tick_counter=tick_counter+1;
            DrawFormattedText(win, mask, 'center', 'center', text_color);
            Screen('Flip', win);
            total_experiment_tick_time(tick_counter);
        end
        
        %Prime
        for t1=1:prime_max_frames
            tick_counter=tick_counter+1;
            DrawFormattedText(win, MyTrials(item).prime, 'center', 'center', text_color);
            Screen('Flip', win);
            total_experiment_tick_time(tick_counter);
        end

        
        %Target
        %for t1=1:target_max_frames
        tick_counter=tick_counter+1;
        DrawFormattedText(win, MyTrials(item).target, 'center', 'center', text_color);
        total_experiment_tick_time(tick_counter);
        [Start] = Screen('Flip', win);
        
        %% COLLECTING RESPONSES
        Stat = CedrusResponseBox('FlushEvents', hdl);
        Stat = CedrusResponseBox('ResetRTTimer', hdl);
        
        begin = now; %added by Eis- now is a command that gives the time in days
        tThr = 1.5/(24*3600); %added by Eis- this is a calculation to convert the time from 'now' into seconds
        while ~stop
            if ((now-begin) > tThr) %added by Eis- if the time is greater than 2 seconds
                stop = true;
            end
            event = CedrusResponseBox('GetButtons', hdl);
            if ~isempty(event) % ~isempty checks to see if the vector is empty (button hasn't been pressed)
                if strcmp(event.buttonID, '2.Left') || strcmp(event.buttonID, '6.Left')
                    TempRespTime = event.rawtime; %added by Eis- reaction time
                    MyTrials(item).ResponseTime = TempRespTime;
                end
                if strcmp(event.buttonID, '2.Left')
                    if strcmpi(Handedness, 'D')
                         MyTrials(item).Response = 'nonword';
                    elseif strcmpi(Handedness, 'S')    
                    MyTrials(item).Response = 'word';
                     end
                elseif strcmpi(event.buttonID, '6.Left')
                     if strcmpi(Handedness, 'D')
                         MyTrials(item).Response = 'word';
                    elseif strcmpi(Handedness, 'S')    
                    MyTrials(item).Response = 'nonword';
                     end
                end
                break;
            end
            
            if isempty(event)
                MyTrials(item).ResponseTime= TempRespTime;
                MyTrials(item).Response='NoResponse';
            end
            %  end
        end
        % Give feedback only during the training phase
        if item>n_examples && item<= n_practice + n_examples
            if strcmp(MyTrials(item).Response, MyTrials(item).lexicality) == 0
                Screen('FillRect',win,[ 50 5 5]);
                Screen('Flip', win);
                WaitSecs(0.75);
                Screen('FillRect',win,[0 0 0]);
                Screen('Flip', win);
            end
            WaitSecs(0.001);
        end
        
        %% Add one last frame
        for t1=1:lastframe_duration_sec+1
            tick_counter=tick_counter+1;
            Screen('Flip', win);
            total_experiment_tick_time(tick_counter);
        end
        
        %% Save the trial
        pattern = '%s\t%s\t%s\t%s\t%d\t%s\t%s\t%d\t%s\t%s\n';
        fprintf(fid, pattern, GlobalSubjectID,GlobalExperimentID,GlobalRotationID, Handedness,...
            MyTrials(item).trial_ID, MyTrials(item).prime, MyTrials(item).target, TempRespTime, MyTrials(item).Response, MyTrials(item).lexicality);
        %% Keep iterating
        item = item + 1;
    end
    
    %% Ending the experiment
    DrawFormattedText(win, '[ FINE ESPERIMENTO ]' , 'center', 'center', text_color);
    Screen('Flip', win);
    pause(3);
    
    Screen('CloseAll');
    ShowCursor();
    fclose(fid);
    ListenChar(1);
    clear all;
    close all;
catch me
    disp(me.error)
    Screen('CloseAll');
    rethrow(lasterror);
    ShowCursor();
    ListenChar(1);
    clear all;
    close all;
    
end
Priority(0)