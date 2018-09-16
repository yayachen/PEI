function [recall,GTname,EVAname,GTarray, EVAarray ] = chord_evaluation(EVAdata, GTdata, timeSig, unit)
    if nargin < 3, timeSig = 4; end
    if nargin < 4, unit = 1; end
%     GTFile  = 'b_4_1';%''; trans_chord_k309_m1, trans_chord_k545_m1
%     evaFile = 'trans_b_4_1';
%     [~, ~,  GTdata] = xlsread(['chordGT/' GTFile '.xlsx']);
%     [~, ~, EVAdata] = xlsread(['chordEva/' evaFile '.xlsx']);

    % want to structure

    [GTarray ,GTname ] = toArray( GTdata, unit, timeSig);
    [EVAarray,EVAname] = toArray(EVAdata, unit, timeSig);
%     [size(GTarray) size(EVAarray)]

    Ans = (GTarray-EVAarray==0);
    recall = sum(sum(GTarray-EVAarray==0)) / ( (size(GTarray,1)*size(GTarray,2)) - sum(sum(GTarray==0)) );

    unit = 0.5;
    [GTarray ] = toArray( GTdata, unit, timeSig);
    [EVAarray] = toArray(EVAdata, unit, timeSig);
    ans2 = sum(sum(GTarray-EVAarray==0))/(size(GTarray,1)*size(GTarray,2));
end

 
function [chordNo, chordName] = toArray(data, unit, timeSig)
    barNum      = data{end,1};
    chordNo     = zeros(barNum, timeSig/unit);
    chordName   = repmat({'-'}, barNum, timeSig/unit);%cell (barNum, timeSig/unit);
    
    for i=2:length(data)
        on = floor(data{i,2}/unit)+1; 
        if i~=length(data)
            off = ceil(data{i+1,2}/unit);
            if data{i+1,2}==0; off = timeSig/unit; end
        else
            off = timeSig/unit;
        end
        %把 原本演算法減七和弦 合併為減三和弦的idx
        if data{i,5} > 48
            data{i,5} = mod(data{i,5}, 12) + 36;
        end
        chordNo  (data{i,1}, on:off) = data{i,5};
        chordName{data{i,1}, on}     = data{i,4};
    end
end