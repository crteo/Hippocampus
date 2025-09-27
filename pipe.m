function [] = pipe()
pwd_original = pwd;

% 1. Extract session folders available with the name convention "[Ss]ession0[1-9]"
% Use dir with a pattern to find all folders matching 'Session0X' (case-insensitive)
session_folders = dir('Session0*'); 
% Check if any session folders were found
if isempty(session_folders)
    warning('No session folders matching "[Ss]ession0[1-9]" were found in the current directory.');
    return;
end

fprintf('Found %d session folders to process: %s\n', length(session_folders), strjoin(session_folders, ', '));

% Iterate through each session directory
for i = 1:length(session_folders)
    session_dir_name = session_folders{i};
    fprintf('Processing folder: %s', session_dir_name);
    % cd into each session directory
    try
        cd(session_dir_name);
        % Run the following section in each session directory:
        
        % 1. create a folder called temp
        temp_folder = 'temp';
        if ~exist(temp_folder, 'dir')
            mkdir(temp_folder);
            fprintf('Created folder: %s\n', temp_folder);
        else
            fprintf('Folder "%s" already exists.\n', temp_folder);
        end
        
        % 2. duplicate all .mat objects and store in temp folder
        mat_files = dir('*.mat');
        if isempty(mat_files)
            fprintf('No .mat files found in %s.\n', session_dir_name);
        else
            fprintf('Duplicating %d .mat files to "%s"...\n', length(mat_files), temp_folder);
            for j = 1:length(mat_files)
                source_file = mat_files(j).name;
                destination_file = fullfile(temp_folder, source_file);
                
                % Use 'copyfile' for duplication
                [success, message, ~] = copyfile(source_file, destination_file);
                if ~success
                    warning('Failed to copy file %s: %s', source_file, message);
                end
            end
            fprintf('Duplication complete.\n');
        end
         % 3. if umaze.mat exists in session folder, delete it
        umaze_file = 'umaze.mat';
        if exist(umaze_file, 'file') == 2
            delete(umaze_file);
            fprintf('Deleted file: %s\n', umaze_file);
        else
            fprintf('%s does not exist, skipping deletion.\n', umaze_file);
        end
        
        % cd back out to the original directory
        cd(pwd_original);
        
    catch ME
        warning('An error occurred while processing %s: %s', session_dir_name, ME.message);
        % Attempt to safely return to the original directory before continuing the loop
        if ~strcmp(pwd, pwd_original)
            cd(pwd_original);
        end
    end
end

fprintf('\n Processing complete. Returned to original directory: %s \n', pwd_original);

end
aligning_objects();
uma = umaze('auto');
save('umaze.mat', "uma");