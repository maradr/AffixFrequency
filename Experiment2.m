%% Experiment II: Masked priming lexical decision
% Letter chunk frequency does not explain morphological masked priming : Affix frequency in masked priming
% De Rosa, M. - March 2021

% MP with lexical decision;
% Randomization of items within each single session;
% Present stimuli;
% Collect responses & RTs
% Check for bad ticks in stimuli presentation

% Note: code calls for two auxiliary scripts:
% - FirsThingsFirst
% - Randomization

%% Start a new session
FirstThingsFirst
opengl hardware; %uses a hardware-accelerated version of OpenGL to render subsequent graphics.
rng(str2double(regexp(E.info.sbjID,'[0-9]*','match'))) %seed for sbj
Randomization

global  Start stop RT

try
    %% The Screen
    back_color=0; %black>> PsychtoolboxVersion
    text_color=100; %grey. Other option: 140
    TextSize=32;
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'Verbosity', 0);
    win = Screen('OpenWindow', 0, back_color); %, [100 100 1300 1300]); %[0 0 640 480]);
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
    HideCursor();
    %Centering
    
    [width, height]=Screen('WindowSize', 0); %get size in pixel of second monitor
    MaxDXpixel=width;
    MaxDYpixel=height;
    shCenter = (MaxDXpixel)/2;
    svCenter = (MaxDYpixel)/2;
    
    %% TIMING: Refresh rates and stimuli duration
    f_rate = Screen('NominalFrameRate', win);
    E.screen.f_rate = f_rate;
    % set the duration of each phase
    interstimulis_interval_sec=1.5;
    mask_duration_sec=0.5;
    prime_duration_sec= 0.050;
    target_duration_sec= 1.5;
    lastframe_duration_sec= 0.5;
    
    % multiply the duration in seconds for the refresh rate
    interstimulis_interval_max_frames=fix(interstimulis_interval_sec*f_rate);
    mask_max_frames=fix(mask_duration_sec*f_rate);
    prime_max_frames=fix(prime_duration_sec*f_rate);
    target_max_frames=fix(target_duration_sec*f_rate);
    lastframe_duration_sec=fix(lastframe_duration_sec*f_rate);
    
    %% Instructions
    instructions_Start = {'Premi il tasto centrale per cominciare'};
    instructions_TrueStart = {'Ottimo!\n\nSe non hai domande,\n\npremi il tasto centrale per iniziare l''esperimento.'};
    if strcmpi(E.info.Hand, 'D')
        instructions_Explanation = {'Benvenuto!\n\nIn questo esperimento vedrai alcune sequenze di lettere.\n\nPer ogni presentazione dovrai decidere\n\nse la sequenza che vedi e'' una parola realmente esistente in italiano.';
            'In ogni presentazione vedrai una serie di cancelletti \n\ne subito dopo la parola da classificare.\n\n\nSe la parola esiste \n\npremi il tasto VERDE.\n\n\n\nSe la parola non esiste, \n\npremi il tasto GIALLO.';
            'Fai attenzione!\n\nDovrai rispondere\n\nin modo RAPIDO e ACCURATO.\n\nSii piu'' veloce che puoi. \n\nPremi il tasto centrale per vedere 2 esempi.'};
        instructions_Training = {'Ricorda!\n\nSe la parola esiste, \n\npremi il tasto VERDE.\n\n\n\nSe la parola non esiste in italiano, \n\npremi il tasto GIALLO.';
            'Cerca di essere RAPIDO e ACCURATO.';
            'Facciamo un po'' di pratica:\n\nSe sarai troppo lento nel dare la risposta \n\no se darai la risposta sbagliata \n\nlo schermo si colorera'' di rosso.\n\nPremi il tasto centrale per fare alcune prove!'};
    elseif strcmpi(E.info.Hand, 'S')
        instructions_Explanation = {'Benvenuto!\n\nIn questo esperimento vedrai alcune sequenze di lettere.\n\nPer ogni presentazione dovrai decidere\n\nse la sequenza che vedi e'' una parola realmente esistente in italiano.';
            'In ogni presentazione vedrai una serie di cancelletti \n\ne subito dopo la parola da classificare.\n\nSe la parola esiste \n\npremi il tasto GIALLO.\n\n\n\nSe la parola non esiste, \n\npremi il tasto VERDE.';
            'Fai attenzione!\n\nDovrai rispondere\n\nin modo RAPIDO e ACCURATO.\n\nSii piu'' veloce che puoi. \n\nPremi il tasto centrale per vedere 2 esempi.'};
        instructions_Training = {'Ricorda!\n\nSe la parola esiste, \n\npremi il tasto GIALLO.\n\n\n\nSe la parola non esiste in italiano, \n\npremi il tasto VERDE.';
            'Cerca di essere RAPIDO e ACCURATO';
            'Facciamo un po'' di pratica:\n\nSe sarai troppo lento nel dare la risposta \n\no se darai la risposta sbagliata \n\nlo schermo si colorera'' di rosso.\n\nPremi il tasto centrale per fare alcune prove!'};
    end
    %% Delivery
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
    
    %% loop for presentation of the stimuli
    item = 1;
    while (item<=10)%length(ExperimentalList))
        WaitSecs(rand*0.2); % Random variation to variate the interstimulus interval
        Start=0;
        stop=0;
        RT=0;
        %% Loop for stimuli presentation:
        Screen('FillRect',  win, back_color);
        Screen('Flip', win);
        %% Displaying Conditional Instructions
       if item==n_examples+1
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
            Screen('Flip', win);
        end
        
        %Mask
        for t1=1:mask_max_frames
            DrawFormattedText(win, mask, 'center', 'center', text_color);
            Screen('Flip', win);
        end
        
        %Prime
        for t1=1:prime_max_frames
            DrawFormattedText(win, ExperimentalList(item).prime, 'center', 'center', text_color);
            Screen('Flip', win);
        end
        
        
        %Target
        %for t1=1:target_max_frames
        DrawFormattedText(win, ExperimentalList(item).target, 'center', 'center', text_color);
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
                    RT = event.rawtime; %added by Eis- reaction time
                    ExperimentalList(item).ResponseTime = RT;
                end
                if strcmp(event.buttonID, '2.Left')
                    if strcmpi(E.info.Hand, 'D')
                        ExperimentalList(item).response = 'nonword';
                    elseif strcmpi(E.info.Hand, 'S')
                        ExperimentalList(item).response = 'word';
                    end
                elseif strcmpi(event.buttonID, '6.Left')
                    if strcmpi(E.info.Hand, 'D')
                        ExperimentalList(item).response = 'word';
                    elseif strcmpi(E.info.Hand, 'S')
                        ExperimentalList(item).response = 'nonword';
                    end
                end
                break;
            end
            
            if isempty(event)
                ExperimentalList(item).ResponseTime= 0;
                ExperimentalList(item).response='NoResponse';
            end
            %  end
        end
        % Give feedback only during the training phase
        if item>n_examples && item<= n_practice + n_examples
            if strcmp(ExperimentalList(item).response, ExperimentalList(item).lexicality) == 0
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
            Screen('Flip', win);
        end
        
        %% Save the trial
        %% Write down the trial output
        E.thelist = ExperimentalList; %save in the bigger structure
        save(fullfile(output_directory ,E.filename), 'E');
        fprintf(fid, pattern,  E.info.expID,E.info.sbjID,E.info.rotation,E.info.Hand, ...
            ExperimentalList(item).trial_ID, ExperimentalList(item).prime,...
            ExperimentalList(item).target, ExperimentalList(item).ResponseTime,...
            ExperimentalList(item).response, ExperimentalList(item).lexicality);
        %% Keep iterating
        item = item + 1;
    end
catch
    ShowCursor();
    sca
    ple
end

%% Closing Remarks
for i=1:length(ExperimentalList)
    ExperimentalList(i).acc = isequal(ExperimentalList(i).response, ExperimentalList(i).lexicality);
end

goodbye = ['Ecco il tuo risultato finale: ' num2str((mean([ExperimentalList.acc]))*100) '% \n\n Grazie!'];
Screen('Flip', win);
DrawFormattedText(win, goodbye, 'center', 'center');
Screen('Flip', win);
WaitSecs(3)

%% One last saving!
save(fullfile(output_directory,E.filename), 'E');
Screen('CloseAll');
fclose(fid);
ShowCursor();
Priority(0)