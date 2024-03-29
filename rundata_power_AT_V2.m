% 5/1/19 - seems to work well for PT8
%V2 on 4/30/19 - using to test with our io data


subj = 'PT8';

% below is original code from Zag and above are some inputs I've added 
%
% close all; clear all;

% homeDir = 'Users/andytek/Desktop/SeqMemRawdata/'; %zag directory on AT laptop
homeDir = 'Users/andytek/Desktop/humanIO_folders_movedfromdesktop_11_13_18/';

% filenames=filenames_SequenceMem('macroSTN');% must set to 'ALL', or 'ALLSTN', or 'macroSTN', or 'microSTN', or 'Frontal', or 'Lateral'
%AT, so the above gives struct output that lists a 'stem' in column 1 with
%some number of 'channelnames' in column 2; cell formats. seems like it'd
%be part of the path but doesnt make sense to me

filenames = 'BlwTrgt_8_01883';  %AT, ephys LFP


%option parameters
normalize=1; % set to 1 to plot the data as % change from baseline. set to 0 to plot raw power. 

Duration=2.000; % time duration of each event in seconds
Offset=.500;% Offset is the time you want to go back by. ie. Offset=.500; means 500ms BEFORE event began will be start of each trial

% LFPSamplerate=1000;
LFPSamplerate = 1375; %AT

Buffer=1000; waveletwidth=6;
filelength=LFPSamplerate*Duration;
if normalize==1
    Offset_cue=.375;
    Duration_cue=0.250;
end
time=-(Offset-1/LFPSamplerate):1/LFPSamplerate:(-Offset+Duration); % set the time axis
freqs=2.^((8:54)/8); %AT

%set up file output names
%AT 4/26/19 - below are what zag used, will need to replace with whatever
%makes sense

% % label='_targVSdist';
% % percnorm='';if normalize==1; percnorm='_percnorm'; end
% % powerlabel = ['waveletpower_induced&evoked' percnorm label '.mat']; 

%% LOOK AT PHASE DATA

tstart=tic;
for i=1:length(filenames)
%     i
       
%         close all %AT idk why they have this here
       
%         subj=filenames(i).channelnames{j}(1:6);
%         session=filenames(i).channelnames{j}(regexp(filenames(i).channelnames{j}, 'sess','end')+1);
%         channel = filenames(i).channelnames{j}(regexp(filenames(i).channelnames{j},'\.'):end);

%below are AT substitutions for above

       PT = subj; %AT

        
        
        
        %load Events.mat
%         load([homeDir subj '/behavioral/session_' session '/events.mat']);
%         
        %AT below for PT 8
        load ([homeDir PT '/input_matrix_rndm_August13th']) %AT loads input matrix
        load ([homeDir PT '/rsp_master_v3']) %AT loads rsp
        
        
        
        
        % get the correct trials for low and high conflict
%         targ_correct=find([events.correct]==1 & [events.target]==1 | [events.correct]==2 & [events.target]==0 ); 
%         dist_correct=find([events.correct]==1 & [events.target]==0 | [events.correct]==2 & [events.target]==1 ); 
%         
        %AT so to mimic, I think I index for correct and then incorrect
        %trials (I think that 'targ' first statement is participant correctly recalling when they need to, second statement is them correctly not recalling when it is not in target (?); second statement I guess is the inverse of what I just wrote)
        
        %AT uncomment below when using our data
        [L_IS_correct_structs,  R_IS_correct_structs,  L_SG_correct_structs, R_SG_correct_structs] = io_taskindexing_AT_V1(rsp_master_v3, input_matrix_rndm);
% 
%         events_low=events(targ_correct);
%         events_high=events(dist_correct);
%         events_joint=[events_low, events_high];
%         
        %AT uncomment below when using our data
        events_SGjoint=[L_IS_correct_structs, R_IS_correct_structs];
        events_ISjoint=[L_SG_correct_structs, R_SG_correct_structs];
        events_joint = [events_SGjoint, events_ISjoint]; %unsure if this will be used, but prob
    
%         % load the EEG data         
%         filename=[homeDir subj '/ecogLFPdata_rereferenced/' events(1).eegfile channel];
%         fchan_reref = fopen(filename,'r','l'); %so this opens the specified filename as a read only, below fx do something similar, JT pointed out this is probably so that they can store the file in a text version, which is much more compact than trying to store the 16 bit info for each sampling point
%         LFP_wholerecordings=fread(fchan_reref,inf,'int16');
%         fclose(fchan_reref);
%         LFP_joint=zeros(length(events_joint), Duration*1000+2*Buffer);%note, 'Duration*1000+2*Buffer' equals 4000
        
        filename = [homeDir PT '/' filenames];   % AT
        load(filename);
         
%         LFP_wholerecordings_uint16 = CLFP_01; 
%         LFP_wholerecordings_uint16 = CLFP_02; 
%         LFP_wholerecordings_uint16 = CMacro_LFP_01; 
        LFP_wholerecordings_uint16 = CMacro_LFP_02; 

        LFP_wholerecordings = double(LFP_wholerecordings_uint16);
        
        conversionfactor = lfp.sampFreqHz/1000;

        LFP_joint=zeros(length(events_joint), (Duration*1000+2*Buffer)*conversionfactor);%note, 'Duration*1000+2*Buffer' equals 4000



            %checked that 'trial start' output from the TTLnav fx directly matches the rsp output. So the number of TTL's equals the number of non-error'ed trials.
            %87 for pt8 by ttl_nav; 87 for pt8 by iotaskindexing
            
            
%         
%         for event=1:length(events_joint)
%             startindex=events_joint(event).eegoffset-Offset*1000-Buffer; %I believe EEG offset is the timestamp for trial start
%             endindex=startindex-1+Duration*1000+2*Buffer;
%             LFP_joint(event,:)=LFP_wholerecordings(startindex:endindex);
%         end
%         
        
% %         %AT, below is editted version of above, I think things can be
% %         kept pretty constant

       length_lfp_recording = length(LFP_wholerecordings)/lfp.sampFreqHz;

       ioTask_index = io_TTLnavigating_v2(ttlInfo);
       ioTask_index_timestamps = ioTask_index(2,:);
       ioTask_index_timestamps(ioTask_index_timestamps==0) = []; %Note, these are the time stamps for the TTL corresponding to start of the trial. I think I want to convert everything down to seconds for comparison of TTL to LFP to spikes
        ioTask_index_timestamps_secs = ioTask_index_timestamps/44000;
       ioTask_index_timestamps_millisecs = ioTask_index_timestamps_secs * 1000;
        
        
       ttl_LFP_startOffset_secs = ttlInfo.ttlTimeBegin - lfp.timeStart; %TTL recording time begins after LFP since recording starts a bit before task is ready to inititiate
        ttl_LFP_startOffset_milliseconds = ttl_LFP_startOffset_secs*1000;
       ioTask_index_timestamps_millisecs_aligned = ioTask_index_timestamps_millisecs(:) + ttl_LFP_startOffset_milliseconds;     
%so now, because of the above code, the ttl and LFP signals should be
%aligned to one another with these times being in milliseconds

        for t=1:length(events_joint)
            startindex=ioTask_index_timestamps_millisecs_aligned(t)-Offset*1000-Buffer; 
%             endindex=startindex-1+Duration*1000+2*Buffer;
            %so the above is giving us the windows of lfp data we want to
            %group together, in units of milliseconds
            
            startindex_lfp = round(startindex*conversionfactor);
            endindex_lfp = startindex_lfp-1+((Duration*1000+2*Buffer)*conversionfactor);
            LFP_joint(t,:)=LFP_wholerecordings(startindex_lfp:(endindex_lfp));
            
        end
                
        
        
        
        % filter out 60 Hz noise
        LFP_joint=buttfilt(LFP_joint,[59 61], LFPSamplerate, 'stop', 2);
        
        %get the phase and power
        [phaseMat_joint, powerMat_joint]=multiphasevec3(freqs,LFP_joint,LFPSamplerate,waveletwidth);
        %AT 5/1/19; I think for the below fx, it is important to account
        %for different between lfp sampling rate and our millisecond
        %standard. Ultimately we want the last dimension of the
        %phase/powerMat output equal the number of samples in our 'time'
        %variable
        phaseMat_joint = squeeze(phaseMat_joint(:,:,(Buffer*conversionfactor)+1:end-(Buffer*conversionfactor)));
        powerMat_joint = squeeze(powerMat_joint(:,:,(Buffer*conversionfactor)+1:end-(Buffer*conversionfactor)));
        
        % clean the data of artifacts
%         [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 10, find(freqs>1.9 & freqs<8.1),0);
%         [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 25, find(freqs>7.9 & freqs<32.1),0);
%         [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 50, find(freqs>31.9 & freqs<108.1),0); 
%  
        
        [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter_AT_V1(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 10, find(freqs>1.9 & freqs<8.1),0);
        [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter_AT_V1(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 25, find(freqs>7.9 & freqs<32.1),0);
        [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter_AT_V1(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 50, find(freqs>31.9 & freqs<108.1),0); 
 
        
        
        
        
        
        
        
        % reassign the clean data to events. 
%         [events_SGjoint, events_ISjoint]
        
%         
%         [~,lowtrials_clean] = intersect([events_joint.mstime],[events_low.mstime]);
%         [~,hightrials_clean] = intersect([events_joint.mstime],[events_high.mstime]);
%         events_low=events_joint(lowtrials_clean);    powerMat_low=powerMat_joint(lowtrials_clean,:,:);   phaseMat_low=phaseMat_joint(lowtrials_clean,:,:);
%         events_high=events_joint(hightrials_clean);  powerMat_high=powerMat_joint(hightrials_clean,:,:); phaseMat_high=phaseMat_joint(hightrials_clean,:,:);
% 
    
        [~,events_SGjoint_clean] = intersect([events_joint.Wholetrial],[events_SGjoint.Wholetrial]);
        [~,events_ISjoint_clean] = intersect([events_joint.Wholetrial],[events_ISjoint.Wholetrial]);
        events_SGjoint=events_joint(events_SGjoint_clean);    powerMat_SG=powerMat_joint(events_SGjoint_clean,:,:);   phaseMat_SG=phaseMat_joint(events_SGjoint_clean,:,:);
        events_ISjoint=events_joint(events_ISjoint_clean);  powerMat_IS=powerMat_joint(events_ISjoint_clean,:,:);  phaseMat_IS=phaseMat_joint(events_ISjoint_clean,:,:);

          
        
        
        
        
        %get baseline power and normalize
        if normalize==1
            startindex_cue=(Offset-Offset_cue)*1000;
            endindex_cue=startindex_cue+Duration_cue*1000;
            powerMat_cue=[powerMat_SG(:,:,startindex_cue:endindex_cue); powerMat_IS(:,:,startindex_cue:endindex_cue)];
            
            powerMean_cue=mean(squeeze(mean( powerMat_cue,3)));
            powerSTD_cue=std(squeeze(mean( powerMat_cue,3)));
            powerMat_SG=bsxfun(@rdivide,bsxfun(@minus,powerMat_SG,powerMean_cue),powerMean_cue);
            powerMat_IS=bsxfun(@rdivide,bsxfun(@minus,powerMat_IS,powerMean_cue),powerMean_cue);
        end
        powerMean_SG=squeeze(mean(powerMat_SG,1));
        powerMean_IS=squeeze(mean(powerMat_IS,1));
       
        imagescale=[-.75 .75]; 
        figure;
        pcolor(time, freqs,powerMean_SG); %colorbar; 
        set(gca,'CLim',imagescale); 
        shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
        title([PT,',  SG correct trials mean']);
        figure;
        pcolor(time, freqs, powerMean_IS); %colorbar; 
        set(gca,'CLim',imagescale); 
        shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
        title([PT,',  IS correct trials mean']);
        figure;
        pcolor(time, freqs, powerMean_IS-powerMean_SG); %colorbar; 
        set(gca,'CLim',imagescale); 
        shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
        title([PT, ',  Difference between IS and SG means']);

%         % save everything
%         numlow=length(events_low);% 
%         numhigh=length(events_high);% 
%         outputDir=[homeDir filenames(i).channelnames{j} '_power/' ]; if ~exist(outputDir,'dir'); mkdir(outputDir); end 
%         save([outputDir powerlabel], 'powerMean_low','powerMean_high', 'freqs', 'numlow', 'numhigh');
end
toc(tstart)
fprintf('\nAll Done\n')

