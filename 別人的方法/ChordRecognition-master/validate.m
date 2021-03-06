function Res = validate(X,T,W,I)
%X - Data
%T - Test labels of X
%W - Weights (70 + 33)
%I - Indicies of data X to validate (ex. [1:10])
TET = 0;
CORRECT = 0;
N = length(I);
Res = struct('sid', '', 'numEvents', 0, 'oChords', [], 'nChords', [], 'numCorrect', 0, 'ratioCorrect', 0);
for i = 1:N
    ii = I(i);
    Res(i).sid = T(ii).sid;
    Res(i).numEvents = T(ii).numEvents;
    Res(i).oChords = arrayfun(@(x) m_label(x),T(ii).chord, 'UniformOutput', 0);
    
    Hx = carpe_diem_alg(X(ii),W,X(ii).numEvents);
    Hx = Hx - 1;    
    
    Res(i).nChords = arrayfun(@(x) m_label(x),Hx, 'UniformOutput', 0);
    Res(i).numCorrect = sum((Hx - T(ii).chord) == 0);
    Res(i).ratioCorrect = Res(i).numCorrect / Res(i).numEvents;
    
    TET = TET + Res(i).numEvents;
    CORRECT = CORRECT + Res(i).numCorrect;
    fprintf('validate T(%d), %s : CORRECT = %.2f, CUM = %.2f\n', ii, Res(i).sid, Res(i).ratioCorrect*100, CORRECT./TET * 100);
end

fprintf('accuracy: %.2f\n', (sum([Res.numCorrect])/sum([Res.numEvents]) * 100));

end