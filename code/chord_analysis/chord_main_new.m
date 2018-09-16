clear; clc; close all;
addpath('../');
addpath('../toolbox/midi_lib/midi_lib');

isSave = 1;
name = {'m_16_1', 'm_7_1', 'b_4_1', 'b_20_1', 'c_40_1', 'c_47_1', 'h_37_1', 'h_23_1', ...
        'm_16_2', 'm_7_2', 'b_4_2', 'b_20_2', 'h_37_2'};
name = {'m_16_1_4'}
fpath = '../midi/pei/';
% file = dir(fullfile([fpath '*.mid']));

% for i = 1:length(file)
for i = 1:length(name)
    clearvars -except i isSave name fpath file 

%% INPUT : MIDI
%     fname = erase(file(i).name, ".mid")
    fname = name{i};
    
    [midiData, timeSig] = midi_Preprocess([fpath fname]);
    [barNote, barOnset] = bar_note_data(midiData, timeSig); % each bar's information
      
    if strcmp(fname, 'b_20_2'); timeSig(1,:) = []; end % �S���B�z
    
%% �M�����R
    parameter.isNowTemplate = 1;
    parameter.isPartitionDBeat = 1;
    parameter.isDurWeight = 1;

    chordPredict = choral_analysis_modify_new(barNote, barOnset, timeSig(1), parameter);

%% ����
    if timeSig(2) ~= 2 % �]��note�}�C�|�۰ʧ�縹 map�� X/4��A�ҥH���OX/4���n�ഫ�@�U�~�i�H��GT����C
        for t=2:length(chordPredict)
            chordPredict{t, 2} = chordPredict{t, 2}*(2^timeSig(2)/4);
        end
    end

    unit = 0.1; % ���������
    GTdata = csvimport(['../annotation/trans_' fname '.csv']);
    [CSR, chordNameGT, chordNamePredict] = chord_evaluation_new(chordPredict, GTdata, timeSig(1), unit);

% �s��
    if isSave
        save(['chord_result/pei/' fname '.mat'], 'chordPredict');
    end
end
