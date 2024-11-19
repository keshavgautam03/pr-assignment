% Step 0: Unzip the file
zip_file_path = 'D:\PR_ASSIGNMENT.zip';  % Update to the correct path on your system
unzip_dir = 'D:\datasets';  % Destination folder for the unzipped contents

% Check if the ZIP file exists before attempting to unzip
if isfile(zip_file_path)
    unzip(zip_file_path, unzip_dir);  % Extract the ZIP file
    fprintf('ZIP file successfully extracted to "%s".\n', unzip_dir);
else
    error('ZIP file not found at the specified path: %s', zip_file_path);
end

% Step 1: Locate the EMG data and display the number of folders in the dataset
dataset_path = unzip_dir;  % Path to the dataset folder
subjects = dir(dataset_path);
subjects = subjects([subjects.isdir] & ~startsWith({subjects.name}, '.'));  % Exclude '.' and '..'
subject_names = {subjects.name};

fprintf('Number of subject folders in the dataset: %d\n', numel(subject_names));
disp('Subject folders:');
disp(subject_names);

% Initialize results
results = struct();

% Step 2: List the text and log files within each subdirectory and collect additional file information
for i = 1:numel(subject_names)
    subject = subject_names{i};
    subject_path = fullfile(dataset_path, subject);
    
    for action = {'normal', 'aggressive'}
        action_name = action{1};
        
        for folder_type = {'txt', 'log'}  % Iterate over both 'txt' and 'log' folders
            folder_type_name = folder_type{1};
            action_path = fullfile(subject_path, action_name, folder_type_name);
            
            if isfolder(action_path)
                files = dir(fullfile(action_path, '*.txt'));
                log_files = dir(fullfile(action_path, '*.log'));
                files = [files; log_files];  % Combine .txt and .log files
                
                if ~isempty(files)
                    file_info = {};
                    for j = 1:numel(files)
                        file = files(j).name;
                        file_path = fullfile(action_path, file);
                        
                        % Get the size of the file in KB
                        file_info_struct = dir(file_path);
                        file_size = file_info_struct.bytes / 1024;
                        
                        if endsWith(file, '.txt')
                            try
                                data = readmatrix(file_path, 'FileType', 'text', 'Delimiter', ' ');
                                [num_arrays, array_size] = size(data);
                                file_info{end+1} = sprintf('%s (Size: %.2f KB, Rows: %d, Columns: %d)', ...
                                    file, file_size, num_arrays, array_size);
                            catch
                                file_info{end+1} = sprintf('%s (Size: %.2f KB, Rows: Error reading file, Columns: N/A)', ...
                                    file, file_size);
                            end
                        else
                            % For .log files, just print size without counting arrays
                            file_info{end+1} = sprintf('%s (Size: %.2f KB)', file, file_size);
                        end
                    end
                else
                    file_info = {'No files found'};
                end
                
                results(end+1).Subject = subject; %#ok<AGROW>
                results(end).Action = action_name;
                results(end).FolderType = folder_type_name;
                results(end).Path = action_path;
                results(end).Files = file_info;
            else
                results(end+1).Subject = subject; %#ok<AGROW>
                results(end).Action = action_name;
                results(end).FolderType = folder_type_name;
                results(end).Path = action_path;
                results(end).Files = {'Path does not exist'};
            end
        end
    end
end

% Print the table with file size and array details
fprintf('\nFile Information:\n');
for i = 1:numel(results)
    fprintf('Subject: %s | Action: %s | Folder Type: %s | Path: %s\n', ...
        results(i).Subject, results(i).Action, results(i).FolderType, results(i).Path);
    fprintf('Files:\n');
    for j = 1:numel(results(i).Files)
        fprintf('  - %s\n', results(i).Files{j});
    end
    fprintf('%s\n', repmat('-', 1, 60));  % Separator for better readability
end
