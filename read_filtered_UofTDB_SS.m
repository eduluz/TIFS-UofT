% SS = same-session
function [record] = read_filtered_UofTDB_SS()

addpath('./utils') % paar detector de QRS

FreqSample = 200; % hz

load UofTDB.mat

id=1;

for i=1:length(signals)
    i
    data = signals{i}{1}{1};  % primeira sessão, condicao: sentada
  
    if size(data,2) > size(data,1)
        data = data';
    end
    
    if isempty(data) == 0
        tic  
        % filtra sinal
        bpFilt = designfilt('bandpassfir','FilterOrder',4, ...
             'CutoffFrequency1',0.5,'CutoffFrequency2',40, ...
             'SampleRate',FreqSample);

        dataFilt = filtfilt(bpFilt,data);

        % deixa entre 0 e 1
        dataFilt = dataFilt - mean(dataFilt);
        dataFilt = dataFilt + abs( min(dataFilt));
        dataFilt = dataFilt/std(dataFilt);
        dataFilt = dataFilt/max(dataFilt);
       
        % chama o detector de QRS do Hooman Sedghamiz 
        debug = 0;
        [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(dataFilt',FreqSample, debug);

        record{id}.data = dataFilt;
        record{id}.data_outlier = dataFilt;
        record{id}.class = i;
        record{id}.ann = qrs_i_raw - 20; % anotacoes por intervalo de amostras

        id=id+1;
        toc
    end
end
end % fim da funcao

