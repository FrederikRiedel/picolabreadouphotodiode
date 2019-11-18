close all
clear all

folder = '/media/fr649/fredsdata/data/H2O2-stuff/photodiss/20181213-00';
file = '20181213-00';
num_files = 200;

datafiles = [18,16,14,12,10,8,6,4];

iter = 1;

%for iter=1:length(datafiles)
%    clearvars -except folder file num_files datafiles iter

    tic
    parfor k=1:num_files
    
        %k
    
        %filename = strcat(folder,file,num2str(k,'%03d'),'.txt');
        filename = strcat(folder,num2str(datafiles(iter),'%02d'),'/',file,num2str(datafiles(iter),'%02d'),'_',num2str(1,'%03d'),'.txt');
        delimiter = '\t';
        startRow = 3;
        formatSpec = '%f%f%f%f%[^\n\r]';
        fileID = fopen(filename,'r');
        textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false, 'EndOfLine', '\r\n');
        dataArray{k} = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false);
        %table(dataArray{1:end-1}, 'VariableNames', {'Time','ChannelA','ChannelB'});
        fclose(fileID);

    %hold on

    %plot(dataArray{k}{1,1},dataArray{k}{1,2})
    %plot(dataArray{k}{1,1},dataArray{k}{1,3})


    end
    toc
%for k = 1:1900
%    pulsemean(k) = mean(pulse((1:100)+k));
%    pulsestd(k) = std(pulse((1:100)+k));
%    
%end
    
    avggraph = linspace(0,0,length(dataArray{1}{1,3}))';

    tic
    parfor k = (1:num_files) + 0
    
        %k
    
        f = fit(dataArray{k}{1,1}(200:800),dataArray{k}{1,3}(200:800)-mean(dataArray{k}{1,3}(200:800)),'sin1');
        avggraph = dataArray{k}{1,3}-f(dataArray{k}{1,1})+mean(dataArray{k}{1,3}(200:800)) +avggraph;
   
        datamean(k) = mean(dataArray{k}{1,3}(200:800));
   
        Min = min(dataArray{k}{1,3});
    
        pulse(k)= datamean(k)-Min;
   
        photodiode(k) = max(dataArray{k}{1,4})-min(dataArray{k}{1,4});
   
        %area(k) = sum(-dataArray{k}{1,3}(699:770) + datamean(k));
        area(k) = sum(-dataArray{k}{1,3}(1000:1200) + datamean(k));
        %area(k) = sum(-dataArray{k}{1,3}(1148:1192) + datamean(k));
   
        ftime = dataArray{k}{1,1}(1130:1200);
        f = fit(ftime,-dataArray{k}{1,3}(1130:1200) + datamean(k),'exp1');
        coeffs = coeffvalues(f);
        lifetimes(k) = coeffs(2);
   
    end
    toc
    %plot(dataArray{1}{1,1},avggraph./num_files,'o','DisplayName','avggraph')

    pulse_corrected = area./photodiode;

    mean(pulse_corrected)
    std(pulse_corrected)

    mean(lifetimes)
    std(lifetimes)

    %B = 1/10*ones(10,1);
    %plot(filter(B,1,pulse_corrected))

    %Fs = 10;
    %L = num_files;
    %f = Fs*(0:(L/2))/L;
    %Y = fft(pulse_corrected);
    %P2 = abs(Y/L);
    %P1 = P2(1:L/2+1);
    %P1(2:end-1) = 2*P1(2:end-1);
    %plot(f,P1)

    save(file,'-v7.3')
    dlmwrite('water.txt',[mean(pulse_corrected),std(pulse_corrected),mean(lifetimes),std(lifetimes)],'-append','precision', '%e')



%end