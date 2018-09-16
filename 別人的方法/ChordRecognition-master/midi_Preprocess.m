function [ result, timeSig ] = midi_Preprocess( midi_fn, track, deTri )

%% Ūmidi�� �� �e�B�z(�h��tri & �˹���) & �p�� bpm
    % input  : �q���s��
    % output : midi ��T 
    
%      1       2        3        4        5        6       7      8(�|�Q�R��)
%    ONSET |  DUR  | CHANNEL | PITCH | VELOCITY | ONSET |  DUR | TRACK |
%   (BEATS)|(BEATS)|         |       |          | (SEC) | (SEC)|       |

%      9       10       11
%    TEMPO | TIME SIGNATURE |
%    (BPM) | (���l) | (����)  |
    
    if nargin < 2, track = 0; end
    if nargin < 3, deTri = 0; end
%     addpath('toolbox/MIDI tool/miditoolbox');
    addpath('toolbox/midi_lib/midi_lib');
    % �{������     
%     midi_fn = 'b_1_1';
%     deTri = 0;
%     track = 1;
    
    midiINFO   = readmidi_java(midi_fn, 1);
%     midiINFO   = readmidi([midi_fp '/' midi_fn '.mid']);
    midiINFO(midiINFO(:,2)==0,:) = [];
    
    % �p�� bpm
%     tempo = tempocurve(midiINFO); tempo(1) = []; tempo(end+1) = tempo(end);
%     midiINFO(:,size(midiINFO,2)+1) = tempo;

    % �p�� time signature
    timeSig     = get_time_signatures(midi_fn);
    midiSize2   = size(midiINFO,2);
    
    for i=1:size(timeSig,1)
        index = find(midiINFO(:,1)>=timeSig(i,5));
        midiINFO(index, midiSize2+1)    = timeSig(i,1) / (2^timeSig(i,2)/4);% timeSig(i,1);
        midiINFO(index, midiSize2+2)    = 4;% 2^timeSig(i,2);
        
    end
    
    if sum(midiINFO(end,1:2))<timeSig(end,5)
        timeSig(end,:)=[]; 
    end
    
    % delete TRI
%     delete = [];
%     
%     if deTri
%         tri = [];
%         beat_dur = [0.125 0.0625 0.0546875];
%         for i=1:length(midiINFO)-2    
%             if ~(midiINFO(i,2)-midiINFO(i+1,2)) && ~(midiINFO(i,4)-midiINFO(i+2,4)) && midiINFO(i,2)<midiINFO(i+2,2) && any(midiINFO(i,2) == beat_dur)
%                 if i==1
%                     tri = [tri i];
%                 else
%                     if midiINFO(i,2) - midiINFO(i-1,2)
%                         tri = [tri i];
%                     end
%                 end
%             end
%         end
%         
%         for tri_no = 1:size(tri, 2)        
%             midiINFO(tri(tri_no), 2) = sum(midiINFO(tri(tri_no):tri(tri_no)+2, 2));
%             midiINFO(tri(tri_no), 7) = sum(midiINFO(tri(tri_no):tri(tri_no)+2, 7));
%             delete = [delete, tri(tri_no)+1, tri(tri_no)+2];          % �R���O tri �� �᭱��� note
%         end
%     end
%     
%   midiINFO(delete, :) = [];
  
  % ������or�C����  ( �q�`�Ʀr�C���O������??
  
  if track == 0
%       midiINFO(:,8) = [];
      result        = midiINFO;
  else
      trackcha   = unique(midiINFO(:,8));

      for t = 1:length(trackcha)
        midi(t).Track       = midiINFO(midiINFO(:,8)==trackcha(t),:);
        midi(t).Track(:,8)  = [];
      end

      result = midi(track).Track;
  end

end

