
id_hist = zeros(1,1020);
conditions_hist = zeros(1,5);
session_hist = zeros(1,6);

for i=1:1020  
    valid_cond = zeros(1,5);
    valid_session= zeros(1,6);
    for j=1:6        
        for k=1:5
            if (isempty(signals{i}{j}{k}) == 0) && (valid_session(1,j) == 0)
                valid_session(1,j) = 1;
                id_hist(1,i) = id_hist(1,i) + 1;
                
                session_hist(1,j) = session_hist(1,j) + 1;
            end
            
            if isempty(signals{i}{j}{k}) == 0 && valid_cond(1,k) == 0
                valid_cond(1,k) = 1;
                conditions_hist(1,k) = conditions_hist(1,k) + 1;
            end
        end
    end    
end

sum(id_hist(1,:)>=2)
