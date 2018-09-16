clear; clc;
setup % <---- kpcorpus1
W = zeros(VERT+HORZ,1);

for loopI = 1%:2
    rand = randperm(length(X));
    folder{1} = rand(1:6);
    folder{2} = rand(7:12);
    folder{3} = rand(13:18);
    folder{4} = rand(19:24);
    folder{5} = rand(25:29);
%     folder{1} = rand(1:12);
%     folder{2} = rand(13:24);
%     folder{3} = rand(25:36);
%     folder{4} = rand(37:48);
%     folder{5} = rand(49:60);

%     for f=1%:5
        %% train
%         testIdx = folder{f};
%         trainIdx = setdiff(rand, folder{f});
%         I = trainIdx
        perceptron_skel

        %% test
%         I = testIdx
        I = 1:29
        Res = validate(X,T,W,I);
%%
        for n = 1:length(I)
            songI = I(n);
            filename = X(songI).sid;
            [ly,info] = get_lyrics_as_text(['DataProcessing/kpcorpus1/' filename '.mid']);
            [midiData, timeSig] = midi_Preprocess(['DataProcessing/kpcorpus1/' filename '.mid']);
            [~, barOnset, midiData] = bar_note_data(midiData, timeSig); % each bar's information
            noteNum(songI,1) = length(unique(midiData(:,1)));
            
            %%
            chordGT = getChordInfo(Res(n).oChords, midiData, timeSig);
            chordHMM = getChordInfo(Res(n).nChords, midiData, timeSig);

            cell2csv(['GT/' filename '.csv'], chordGT);
%             cell2csv(['HMM_EVA/HMM_' filename '.csv'], chordHMMeva);

%             my evaluation mehod
            timesig = timeSig(1);
            unit = 0.1;
            [recall,GTname,EVAname,GTarray, EVAarray] = chord_evaluation(chordHMM, chordGT, timesig, unit);
            CSR(songI) = recall;
%             csr(f) = recall;
        end 
%         [' times, folder '  num2str(f) ', avgCSR = ' num2str(mean(csr))]
%     end
%     CSRmean(loopI) = mean(CSR);
%     ['Loop ' num2str(loopI) ', 總 avgCSR = ' num2str(mean(CSR))]
end
%% => error 11 22 27 32 37 40 43
%           2 . 7 . 11 . 17 . 19 .  22 . 24 . 

% => error 11 22 25 27 32 37


function [chordGT] = getChordInfo(chordLabel, midiData, timeSig)
    global CHORD_L;
    lyChordMap  = {  'M',   'V',   'm',   'd',    'd',    'd'};
    lyChordTempIdx = [ 1,    2,     3,      4,      4,     4];
    rootLetter  = {'C' 'B#' 'C#' 'Db' 'D' 'D#' 'Eb' 'E' 'Fb' 'F' 'E#' 'F#' 'Gb' 'G' 'G#' 'Ab' 'A' 'A#' 'Bb' 'B' 'Cb'};
    rootNum     = [ 1   1    2    2    3   4    4    5   5    6   6    7    7    8   9    9    10  11   11   12  12];

    typeNum = 1:size(CHORD_L, 2);
    chord = [];
    chordId = zeros(length(chordLabel), 1);
    chordTampIdx = zeros(length(chordLabel), 1);

    for i=1:length(chordLabel)
        chordPart = strsplit(chordLabel{i}, '_');
        rL = chordPart(1);
        ml = chordPart(2);
        m = unique(lyChordTempIdx(strncmp(lyChordMap, ml, 3)));
        r = rootNum(strcmp(rootLetter,rL));

        chordId(i,1) = size(typeNum,2)*(r-1) + (m-1);
        chordTampIdx(i,1) = 12 * (m - 1) + r;
        chord = [chord; chordPart];
    end
    onset = unique(midiData(:,1));
    GTtrans = find(diff(chordId)~=0) + 1;
    GTchordTampIdx = [chordTampIdx(1); chordTampIdx(GTtrans)];

    beatALL = [0; onset(GTtrans,1)];
    measure = floor(beatALL/(timeSig(1)/(2^timeSig(2)/4)))+1;
    beat = mod(beatALL,(timeSig(1)/(2^timeSig(2)/4)));
    change = find(diff(measure')) + 1;
    j = 1;
    chordGT = cell(1,6);%{'小節','拍數(onset)','調性','和弦','和弦編號','備註'};
    
    for i = 1:length(measure)
        chordGT{i,1} = measure(i);
        chordGT{i,2} = beat(i);
        if any(change == i) && beat(i)~=0
            temp{j,1} = measure(i);
            temp{j,2} = 0;
            temp{j,4} = chordGT{i-1,4};
            temp{j,5} = chordGT{i-1,5};
            j = j + 1;
        end
        if i == 1
            chordGT{i,4} = [chord{1,1} ':' chord{1,2}];
        else
            chordGT{i,4} = [chord{GTtrans(i-1),1} ':' chord{GTtrans(i-1),2}];
        end
        chordGT{i,5} = GTchordTampIdx(i);
    end
    temp{1,6}=[];
    chordGT = [chordGT; temp];
    [n, sortIdx] = sortrows(sum([cat(1,chordGT{:,1})*10 cat(1,chordGT{:,2})],2),1);
    chordGT = chordGT(sortIdx,:);

    lack = setdiff((1:midiData(end, 11))*10, n);
    for i=1:length(lack)
        tmp{i,1} = lack(i)/10;
        tmp{i,2} = 0;
        idx = find(n<lack(i));
        tmp{i,4} = chordGT{idx(end),4};
        tmp{i,5} = chordGT{idx(end),5};
    end
    tmp{1,6} = [];
    chordGT = [chordGT; tmp];
    [n, sortIdx] = sortrows(sum([cat(1,chordGT{:,1})*10 cat(1,chordGT{:,2})],2),1);
    chordGT = chordGT(sortIdx,:);
    
    if timeSig(2) ~= 2
        for i=2:length(chordGT)
            chordGT{i, 2} = chordGT{i, 2}*(2^timeSig(2)/4);
        end
    end
    
%     if chordGT{end,1} ~= midiData(end, 11)
%         len = size(chordGT,1);
%         for j=1:size(chordGT,2)
%             chordGT{len+1,j} = chordGT{len,j}; 
%         end
%         chordGT{len+1,1} =  midiData(end, 11);
%         chordGT{len+1,2} =  0;
%     end
    word = {'小節','拍數(onset)','調性','和弦','和弦編號','備註'};
    chordGT = [word; chordGT];
end
