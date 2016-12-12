function [new_records] = outlier_removal_UofTDB_SS(records, sizeBeat)

new_records = [];

freqSample = 200;

display('cria estatisticas para outliers..')
for k=1:length(records)
    %k
    
    it=1;

    ecgDII = records{k}.data_outlier; % vetor para derivaçao DII
   
    ecgDII = ecgDII';
    
    anns = records{k}.ann;

    train_ecg{k}.wave = [];
    
    for i=1:length(anns)
        
        bwnd = freqSample/5; % 200ms
        fwnd = sizeBeat-bwnd; 

        if anns(i) - bwnd + 1 <= 0
            startPoint = 1;
        else
            startPoint = anns(i) - bwnd + 1;
        end

        if(anns(i) + (fwnd)  > size(ecgDII,2))
            endPoint = size(ecgDII,2);
        else
            endPoint = anns(i) + (fwnd);
        end

        beatWaveDII = ecgDII(1,startPoint : endPoint) ;
        
            if length(beatWaveDII)==sizeBeat
                valid=1;
                
                % criterio 1: se valor maximo nao for o QRS, exclui
                max_pos = find(beatWaveDII==max(beatWaveDII));
                records{k}.ann_valid(i)=1;

                if max_pos <= (bwnd-3)
                    valid=0;
                end

                if max_pos >= (bwnd+3)
                    valid=0;
                end
                
                if valid==1
                    train_ecg{k}.wave(it,:)=beatWaveDII;
                    it=it+1;
                end
            end
            
    end
    
    if isempty(train_ecg{k}.wave)
        train_ecg{k}.wave(1,:) = zeros(1,sizeBeat);
    end
end

for k=1:length(records)
    %k
    
    it=1;

    ecgDII = records{k}.data_outlier; % vetor para derivaçao DII
   
    ecgDII = ecgDII';
    
    anns = records{k}.ann;

    try
        mean_ecg = mean(train_ecg{k}.wave,1);

        for i=1:length(anns)

            bwnd = freqSample/5; % 200ms
            fwnd = sizeBeat-bwnd; 

            if anns(i) - bwnd + 1 <= 0
                startPoint = 1;
                %abort = 1;
            else
                startPoint = anns(i) - bwnd + 1;
            end

            if(anns(i) + (fwnd)  > size(ecgDII,2))
                endPoint = size(ecgDII,2);
                %abort = 1;
            else
                endPoint = anns(i) + (fwnd);
            end

            beatWaveDII = ecgDII(1,startPoint : endPoint) ;

                if length(beatWaveDII)==sizeBeat
                    valid=1;
                    % criterio 1: se valor maximo nao for o QRS, exclui
                    max_pos = find(beatWaveDII==max(beatWaveDII));
                    records{k}.ann_valid(i)=1;

                    if max_pos <= (bwnd-3)
                        valid=0;
                    end

                    if max_pos >= (bwnd+3)
                        valid=0;
                    end

                    if valid==1

                        try
                            d_mean(k,it) = pdist2(beatWaveDII,mean_ecg,'euclidean');
                        catch
                            size(beatWaveDII)
                            size(mean_ecg)
                            exit;
                        end

                        it=it+1;
                    end
                end

        end
    
    catch
        k
        display('registro sem batimentos!')
    end
end

    %% Utiliza criterios prpostos em: Finger ECG Signal for User Authentication: Usability and Performance (BTAS,2013)
display('remove os outliers..')
for k=1:length(records)
    %k
    fprintf('.')
    ecgDII = records{k}.data_outlier; % vetor para derivaçao DII

    ecgDII = ecgDII';
    
    anns = records{k}.ann;

    mean_ecg = mean(train_ecg{k}.wave,1);
    
    for i=1:length(anns)
        
        bwnd = freqSample/5; % 200ms
        fwnd = sizeBeat-bwnd; 

        if anns(i) - bwnd + 1 <= 0
            startPoint = 1;
        else
            startPoint = anns(i) - bwnd + 1;
        end

        if(anns(i) + (fwnd)  > size(ecgDII,2))
            endPoint = size(ecgDII,2);
        else
            endPoint = anns(i) + (fwnd);
        end

        beatWaveDII = ecgDII(1,startPoint : endPoint) ;
        
        if length(beatWaveDII)==sizeBeat
            
            % criterio 1: se valor maximo nao for o QRS, exclui
            max_pos = find(beatWaveDII==max(beatWaveDII));
            records{k}.ann_valid(i)=1;

            if max_pos <= (bwnd-3)
                records{k}.ann_valid(i)=0;
            end

            if max_pos >= (bwnd+3)
                records{k}.ann_valid(i)=0;
            end

            d = abs(pdist2(beatWaveDII, mean_ecg,'euclidean'));

            % remove hearbets with distance > mean + 1*std
            if d > abs((mean(d_mean(k,:))+(1.0*std(d_mean(k,:)))))
                records{k}.ann_valid(i)=0;
            end

        else
            records{k}.ann_valid(i)=0;
        end
        
    end
end

fprintf('\n')

T = 0; % total number of events (QRS detected)
V = 0; % valid events after outlier removal
for i=1:length(records)
    total = size(records{i}.ann,2);
    T = T + total;
    bad = total - sum(records{i}.ann_valid);
    validos = total - bad;
    V = V + validos;
end

fprintf('total number of events (QRS detected) = %d', T)
fprintf('valid events after outlier removal = %d', V)

new_records = records;


end