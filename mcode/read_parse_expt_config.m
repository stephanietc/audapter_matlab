function config=read_parse_expt_config(configFN)
if ~isfile(configFN)
    error('Configuration file %s does not exist.', configFN);
end

fid1=fopen(configFN,'r');

a=textscan(fid1,'%s','delimiter','\n');
a=a{1};
fclose(fid1);

config=struct;
items={ {'SUBJECT_ID', 'str'}, ...
        {'SUBJECT_GENDER', 'str'}, ...
        {'SUBJECT_DOB', 'str'}, ...
        {'SUBJECT_GROUP', 'str'}, ...
        {'DATA_DIR', 'str'}, ...
        {'DEVICE_NAME', 'str'}, ...
        {'ALWAYS_ON', 'num'}, ...
        {'N_RAND_RUNS', 'num'}, ...
        {'N_BLOCKS_PER_RAND_RUN', 'num'}, ...
        {'TRIALS_PER_BLOCK', 'num'}, ...
        {'SUST_TRIALS_PER_BLOCK', 'num'}, ...
        {'TRIAL_TYPES_IN_BLOCK', 'str'}, ...
        {'MIN_DIST_BETW_SHIFTS', 'num'}, ...
        {'FULL_SCHEDULE_FILE', 'str'}, ...
        {'ONSET_DELAY_MS', 'str'}, ...
        {'NUM_SHIFTS', 'str'}, ...
        {'INTER_SHIFT_DELAYS_MS', 'str'}, ...
        {'PITCH_SHIFTS_CENT', 'str'}, ...
        {'INT_SHIFTS_DB', 'str'}, ...
        {'F1_SHIFTS_RATIO', 'str'}, ...
        {'F2_SHIFTS_RATIO', 'str'}, ...
        {'SHIFT_DURS_MS', 'str'}, ...
        {'SUST_ONSET_DELAY_MS', 'str'}, ...
        {'SUST_NUM_SHIFTS', 'str'}, ...
        {'SUST_INTER_SHIFT_DELAYS_MS', 'str'}, ...
        {'SUST_PITCH_SHIFTS_CENT', 'str'}, ...
        {'SUST_INT_SHIFTS_DB', 'str'}, ...
        {'SUST_F1_SHIFTS_RATIO', 'str'}, ...
        {'SUST_F2_SHIFTS_RATIO', 'str'}, ...
        {'SUST_SHIFT_DURS_MS', 'str'}, ...
        {'INTENSITY_THRESH', 'num'}, ...
        {'TRIGGER_BY_MRI_SCANNER', 'num'}, ...
        {'MRI_TRIGGER_KEY', 'str'}, ...
        {'FMRI_TA', 'num'}, ...
        {'SHOW_KIDS_ANIM', 'num'}, ...  
        {'MOUTH_MIC_DIST', 'num'}, ...
        {'SPL_TARGET', 'num'}, ...
        {'SPL_RANGE', 'num'}, ...
        {'VOWEL_LEN_TARG', 'num'}, ...
        {'VOWEL_LEN_RANGE', 'num'}, ...
        {'STIM_UTTER', 'str_cell'}, ...
        {'SUST_STIM_UTTER', 'str_cell'}, ...
        {'PRE_REPS', 'num'}, ...
        {'PRACT1_REPS', 'num'}, ...
        {'PRACT2_REPS', 'num'}, ...
        {'SUST_START_REPS', 'num'}, ...
        {'SUST_RAMP_REPS', 'num'}, ...
        {'SUST_STAY_REPS', 'num'}, ...
        {'SUST_END_REPS', 'num'}, ...
        {'TRIAL_LEN', 'num'}, ...
        {'TRIAL_LEN_MAX', 'num'}, ...
        {'SAMPLING_RATE', 'num'}, ...
        {'FRAME_SIZE', 'num'}, ...
        {'DOWNSAMP_FACT', 'num'}, ...
        {'NOISE_REPS_RATIO', 'num'}, ...
        {'SMN_GAIN', 'num'}, ...
        {'SMN_FF_0', 'num'}, ...
        {'SMN_FF_1', 'num'}, ...
        {'SMN_ON_RAMP', 'num'}, ...
        {'SMN_OFF_RAMP', 'num'}, ...
        {'BLEND_NOISE_DB', 'num'}, ...
        {'PVOC_FRAME_LEN', 'num'}, ...
        {'PVOC_HOP', 'num'}, ...
        {'OST_FN', 'str'}, ...
        {'OST_MAX_STATE', 'num'}, ...
        {'PERT_STATES', 'num_array'}, ...
        {'STEREO_MODE', 'str'}};

for i1=1:numel(items)
    item=items{i1};
       
    bFound=0;
    for j1=1:numel(a)
        adb = deblank(a{j1});
        if length(adb) >= 1 && isequal(adb(1), '%')
            continue;
        end
        
        if ~isempty(strfind(a{j1},item{1}))
            bFound=1;
            break;
        end
    end

    dba=deblank(a{j1});
    
    if bFound==1 && ~isequal(dba(1),'%')
        str=a{j1};
        if iscell(str)
            str=str{1};
        end
        str=strrep(str, item{1}, '');
        if ~isempty(strfind(str, '%'))
            idxp=strfind(str,'%');
            str=str(1:idxp(1)-1);
        end
    else
        fprintf('WARNING: item %s not specified.\n', item{1});
        config.(item{1})=[];
        continue;
    end
    
    if isequal(item{2}, 'str') 
        str = strtrim(str);
        config.(item{1}) = str;
        
        if isequal(item{1},'SUBJECT_DOB')
            str = strtrim(str);
            config.(item{1}) = str;
            config.EXPT_DATE = date;
            config.SUBJECT_AGE = (datenum(config.EXPT_DATE)-datenum(config.SUBJECT_DOB))/365.2442;
        end
%     elseif isequal(item,'SHIFT_DIRECTION') || isequal(item, 'SHIFT_DIRECTION_SUST') 
%         str=strtrim(str);
%         if isequal(lower(str),'down') || isequal(lower(str),'f1down') || isequal(lower(str),'f1_down')
%             str='F1Down';
%         elseif isequal(lower(str),'up') || isequal(lower(str),'f1up') || isequal(lower(str),'f1_up')
%             str='F1Up';
%         end
%         config.(item{1})=str;
    elseif isequal(item{2}, 'num')
        str = strtrim(str);
        config.(item{1}) = str2double(str);
    elseif isequal(item{2}, 'num_array')
        str = strtrim(str);
        eval(sprintf('config.(item{1}) = %s;', str));
    elseif isequal(item{2}, 'str_cell')
        str=strtrim(str);
        idxs=strfind(str,' ');
        words=cell(1,0);
        
        if isempty(idxs)
            words{end + 1} = str;
        else
            for k1=1:numel(idxs)+1
                if k1==1
                    words{end+1}=str(1:idxs(k1)-1);
                elseif k1==numel(idxs)+1
                    words{end+1}=str(idxs(k1-1)+1:end);
                else
                    words{end+1}=str(idxs(k1-1)+1:idxs(k1)-1);
                end
            end
        end
        config.(item{1})=words;
    end
end

return
