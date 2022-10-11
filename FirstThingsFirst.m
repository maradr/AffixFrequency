%% Beginnings
% Get experiment ID, subject ID, task, font (& open response box if needed)
% Readout the right stimulus file, depending on the rotation% Fields: expID, sbjID, task, font, trialID, probe, position, correct answer,
% answer, RT.
% SD Fields: expID, sbjID, task, font, trialID, probe, distractor, sd, correct answer,
% answer, RT.

clear all; close all; clc
prompt.question{1} ='Experiment ID: ';
prompt.question{2} = 'Subject ID: ';
prompt.question{3} = 'Rotation number: ';
prompt.question{4} = 'Handedness (S | D)? ';

for i = 1:length(prompt.question)
    prompt.answer{i} = input(prompt.question{i},'s');
end

% Collect relevant info
E.info.expID  = prompt.answer{1};
E.info.sbjID  = prompt.answer{2};
E.info.rotation = prompt.answer{3};
E.info.Hand = prompt.answer{4};

filename = ['SL1_2nd_rotation' E.info.rotation '.txt'];
E.info.file=filename;
E.filename = [E.info.expID '_' E.info.sbjID '_' datestr(now, 'dd-mmm-yyyy HH-MM-SS')];

% Read file and dispose mask length.
Table = readtable(char(filename), 'Delimiter', '\t');
mask=repmat('#',1,max(cellfun('length', Table.prime))); % create a mask as long as the longest prime in the session
E.masklength = max(cellfun('length', Table.prime));


%% Response box (CEDRUS)

hdl = CedrusResponseBox('Open', 'COM3'); %open port
boxinfo = CedrusResponseBox('GetDeviceInfo', hdl); %get info from Cedrus
Stat = CedrusResponseBox('FlushEvents', hdl); %get info of button pressed


%% Set the output file
output_directory= 'MPF_2_outputs/';
output_file_name=[output_directory E.info.expID  '_SbjID' E.info.sbjID '.txt'];
fid=fopen(output_file_name,'a');%Global
fprintf(fid,'\n'); %w overwrite
pattern = '%s\t%s\t%s\t%s\t%d\t%s\t%s\t%d\t%s\t%s\n';
fprintf(fid,'experimentID\tsubjectID\troration\thandedness\ttrial_ID\tprime\ttarget\tRT\tresponse\tlexicality\t\n');

clear ('prompt')