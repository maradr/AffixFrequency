%% Rating task 
% Letter chunk frequency does not explain morphological masked priming : Affix frequency in masked priming
% De Rosa, M. - May 2017

% Set the stimuly by taking only the PSEUDOWORDS of the specific rotation;
% Display the stimuli, without checking for the timing (not a variable of
% interest here);
% Collect responses from 1 to 7 through the Cedrus

clear all;
close all;
clc;
opengl hardware; %uses a hardware-accelerated version of OpenGL to render subsequent graphics.
%% Set up materials: global variables; stimuli
global  GlobalExperimentID GlobalSubjectID GlobalRotationID Start TempRespTime

GlobalExperimentID=input('Experiment ID: ', 's');
GlobalSubjectID=input('Subject ID: ', 's');
GlobalRotationID=input('Rotation number: ', 's');

filename = ['Rating' char(GlobalRotationID) '.txt'];
% Load the specific rotation
Table = readtable(char(filename), 'Delimiter', ' '); % define the rotation file
MyTrialsRating = table2struct(Table);
MyTrialsRating = Shuffle(MyTrialsRating);
%% Listen to the response box

hdl = CedrusResponseBox('Open', 'COM3'); %open port
boxinfo = CedrusResponseBox('GetDeviceInfo', hdl); %get info from Cedrus
Stat = CedrusResponseBox('FlushEvents', hdl); %get info of button pressed


%% SCREEN
try
    back_color=0; %black
    text_color=100; %gray. Other option: 140
    TextSize=32;
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'Verbosity', 0);
    
    mywindow = Screen('openWindow', 2, back_color); %,[100 100 1300 1300]); %[0 0 640 480]);
    Screen('Preference', 'TextRenderer', 1);
    Screen('Preference', 'DefaultFontName','Arial');
    Screen('Preference', 'DefaultFontName');
    Screen('TextStyle',mywindow,0);
    Screen('TextFont',mywindow, 'Monospaced');
    Screen('TextFont',mywindow, 'Arial');
    Screen('TextSize',mywindow, TextSize);
    % Prioritize
    PriorityLevel=MaxPriority(mywindow);
    Priority(PriorityLevel);
    
    %Centering
    
    [width, height]=Screen('WindowSize', 2); %get size in pixel of second monitor
    MaxDXpixel=width;
    MaxDYpixel=height;
    shCenter = (MaxDXpixel)/2;
    svCenter = (MaxDYpixel)/2;
    
    %% Set the output file
    output_directory='Rating_outputs';
    output_file_name=[output_directory '/outputExperiment' GlobalExperimentID  '_SubID' GlobalSubjectID  '.txt'];
    fid=fopen(output_file_name,'a');%Global
    fprintf(fid,'\n');
    fprintf(fid,'#SubjectID\tExperimentID\tRotation\tTrialID\tTarget\tResponse\tResponseTime\t\n');
    
    %% Instructions
    instructions_Start = {'Premi il tasto centrale per cominciare'};
    instructions_Explanation = {'Benvenuto!\n\nIn questo esperimento vedrai alcune non-parole.\n\n';
        'Per ogni presentazione dovrai decidere\n\nquanto e'' facile per te dare un significato alla non-parola, da uno a sette.';
        'Ad esempio, la non-parola\n\nPETALOSO\n\n e'' facile da interpretare:\n\npotrebbe significare "pieno di petali, come un fiore".'
        'Al contrario, la non-parola\n\nTAVOLALE\n\n e'' piu'' difficile da interpretare.'
        'Premi il tasto in corrispondenza del numero UNO\n\nse e'' impossibile per te dare un significato alla non-parola.';
        'Premi il tasto in corrispondenza del numero SETTE\n\nse e'' molto facile per te dare un significato alla non-parola.'
        'Prendi pure tutto il tempo necessario\n\nper leggere con attenzione!'};
    instructions_Questions = {'Hai qualche domanda?'};
    instructions_TrueStart = {'Ottimo!';
        'Quando lo sperimentatore ti da'' l''OK,\n\npremi il tasto centrale per iniziare l''esperimento.'};
    %% DISPLAY STIMULI AND COLLECT RESPONSES
    Screen('Flip', mywindow);
    WaitSecs(0.5);
    DrawFormattedText(mywindow, instructions_Start{1}, 'center', 'center', text_color);
    Screen('Flip', mywindow);
    CedrusResponseBox('WaitButtonPress', hdl);
    
    for i= 1:length(instructions_Explanation)
        Screen('Flip', mywindow);
        WaitSecs(0.5);
        DrawFormattedText(mywindow, instructions_Explanation{i}, 'center', 'center', text_color);
        Screen('Flip', mywindow);
        CedrusResponseBox('WaitButtonPress', hdl);
    end
    Screen('Flip', mywindow);
    WaitSecs(0.5);
    DrawFormattedText(mywindow, instructions_Questions{1}, 'center', 'center', text_color);
    Screen('Flip', mywindow);
    CedrusResponseBox('WaitButtonPress', hdl);
    
    for i= 1:length(instructions_TrueStart)
        Screen('Flip', mywindow);
        WaitSecs(0.5);
        DrawFormattedText(mywindow, instructions_TrueStart{i}, 'center', 'center', text_color);
        Screen('Flip', mywindow);
        CedrusResponseBox('WaitButtonPress', hdl);
    end
    while any(Stat(1,:))
        Stat = CedrusResponseBox('FlushEvents', hdl);
    end
    for item =1:length(MyTrialsRating)
        Screen('Flip', mywindow);
        pause(1.5);
        DrawFormattedText(mywindow, MyTrialsRating(item).target, 'center', 'center', text_color);
        %% COLLECTING RESPONSES?
        [Start] = Screen('Flip', mywindow);
        Stat = CedrusResponseBox('FlushEvents', hdl);
        event = CedrusResponseBox('WaitButtons', hdl);
        if ~isempty(event) % ~isempty checks to see if the vector is empty (button hasn't been pressed)
            TempRespTime = event.rawtime; %added by Eis- reaction time
            MyTrialsRating(item).ResponseTime = TempRespTime;
            answer = [event.buttonID(1)];
            %% display the rating given
            feedback = ['La tua risposta e'' ' answer];
            DrawFormattedText(mywindow, feedback, 'center', 'center', text_color);
            Screen('Flip', mywindow);
            pause(2);
        end
        pattern = '%s\t%s\t%s\t%d\t%s\t%s\t%d\n';
        fprintf(fid, pattern, GlobalSubjectID,GlobalExperimentID,GlobalRotationID,...
            MyTrialsRating(item).trial_ID, MyTrialsRating(item).target, answer, TempRespTime);
        
    end
    %% Ending the experiment
    DrawFormattedText(mywindow, '[ FINE ESPERIMENTO ]' , 'center', 'center', text_color);
    Screen('Flip', mywindow);
    pause(4);
    
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
