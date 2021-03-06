% description : 整理每個小節有哪些音，及音符資訊
% input : mididata -> midi資訊
%         timeSig  -> 拍號
% output : barNote -> 每個小節的midi資訊
%          barOnset-> 每個小節開始的beat
function [barNote, onsetBar, midiData] = bar_note_data(midiData, timeSig)
    addBeat     = 0; 
    addBar      = 0; 
    midiSize    = size(midiData, 2);
    
    for i = 1:size(timeSig, 1)
        time = timeSig(i, 1) * (4 / (2^timeSig(i, 2))); % 拍數
        if i ~= size(timeSig, 1)
            barNo = max(ceil( ((timeSig(i + 1, 5) - 1) - timeSig(i, 5) ) / time), 1);
        else
            barNo = max(ceil( ( sum(midiData(end, 1:2)) - timeSig(i, 5) ) / time), 1);
        end

        for j = 1:barNo
            barOnset = addBeat + (j - 1) * time;
            barOffset = addBeat + j * time;
            barNoteIdx = intersect(find(midiData(:, 1) >= barOnset), find(midiData(:, 1) < barOffset));

            currentBar = addBar + j;
            midiData(barNoteIdx, midiSize + 1) = currentBar;
            onsetBar(currentBar) = barOnset;

            % 前個小節圓滑線至此小節的音符slur
            offsetInBarIdx = intersect(find(sum(midiData(:, 1:2), 2) < barOffset), find(sum(midiData(:, 1:2), 2) > barOnset));
            onsetbeforeBarIdx = intersect(find(midiData(:, 1) < barOnset), offsetInBarIdx);
            slurNote = midiData(onsetbeforeBarIdx, :);
            slurNote(:, 2) = sum(slurNote(:, 1:2), 2) - barOnset; % new
%             slurNote(:, 2) = slurNote(:, 2) + barOnset - slurNote(:, 1); 
            slurNote(:, 1) = barOnset; % 把onset改成此小節一開始

            
            noteBar = [midiData(barNoteIdx, :); slurNote]; % 此小節內的音符

            if ~isempty(noteBar)
                noteBar = sortrows(noteBar, 1);
%                 noteBar = trill_detection(noteBar); % tri 處理
%                 noteBar = normalize_midi_data(noteBar);
                noteBar(:,2) = min(sum(noteBar(:,1:2),2), barOffset)-noteBar(:,1); % offset不要超過此小節的offset, new
                
                barNote{currentBar, 1} = noteBar;
            end
        end
        addBar  = addBar  + barNo;
        addBeat = addBeat + time * barNo;
    end
end
