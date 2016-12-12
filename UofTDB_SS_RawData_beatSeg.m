% Autor : Eduardo Luz
% Segmentacao feita por batimento
% SS = same-session : considera todos indivíduos
% sizeBeat : size of heartbeat in ms
function [records] = UofTDB_SS_RawData_beatSeg(sizeBeat)

sizeBeat = sizeBeat/5; % transforma escala : tempo para amostras

display('Le os registros do disco..');
[records] = read_raw_UofTDB_SS();

h = figure;

% histograma # batimentos antes do outlier detection
for tt=1:size(records,2)
    hist_vec(records{tt}.class,1) = size(records{tt}.ann,2);    
end

[records] = outlier_removal_UofTDB_SS(records, sizeBeat);

for tt=1:size(records,2)
    hist_vec(records{tt}.class,2) = sum(records{tt}.ann_valid(:));
end

title('Num batimentos apos Oulier removal');
bar(hist_vec);
savefig(h, 'outlier_result_UofTDB.fig');

         
end


