% Step 0: Extract the ZIP file
zip_file_path = 'D:\sub2-20241119T153807Z-001.zip';  % Path to the uploaded ZIP file
dataset_path = 'D:\datasets';  % Destination folder for the extracted contents

% Check if the ZIP file exists before attempting to extract
if isfile(zip_file_path)
    unzip(zip_file_path, dataset_path);  % Extract the ZIP file
    fprintf('ZIP file successfully extracted to "%s".\n', dataset_path);
else
    error('ZIP file not found at the specified path: %s', zip_file_path);
end

% Step 1: Set the path to the sub2 directory
subject_path = fullfile(dataset_path, 'sub2');

% Step 2: Define a function to read and plot each channel of a specific file
function plot_channels_in_column(action_path, filename, col_index, title_prefix, num_columns)
    file_path = fullfile(action_path, filename);
    if isfile(file_path)
        try
            % Try reading the file assuming space-delimited values
            data = readmatrix(file_path, 'FileType', 'text');
            
            % If the file is empty or not formatted as expected
            if isempty(data)
                error('The file "%s" is empty or incorrectly formatted.', file_path);
            end
            
            % Debugging: Display the first few rows of the data
            fprintf('First few rows of "%s":\n', filename);
            disp(data(1:min(5, size(data, 1)), :));  % Display up to 5 rows

            % Get the number of channels (columns)
            num_channels = size(data, 2);

            % Plot each channel in a subplot
            for channel = 1:num_channels
                subplot(num_channels, num_columns, (channel - 1) * num_columns + col_index);
                plot(data(:, channel), 'LineWidth', 1.2);  % Thicker line for clarity
                title(sprintf('%s - Channel %d', title_prefix, channel));
                xlabel('Sample Index');
                ylabel('Signal Strength');
                grid on;  % Add grid for better visualization
            end
        catch ME
            fprintf('Error reading or plotting "%s": %s\n', filename, ME.message);
        end
    else
        fprintf('File "%s" not found in "%s".\n', filename, action_path);
    end
end

% Step 3: Create a figure and plot both files
figure;

% Plot `waving.txt` from the normal folder in the first column
normal_path = fullfile(subject_path, 'normal', 'txt');
plot_channels_in_column(normal_path, 'waving.txt', 1, 'Normal: Waving', 2);

% Plot `slapping.txt` from the aggressive folder in the second column
aggressive_path = fullfile(subject_path, 'aggressive', 'txt');
plot_channels_in_column(aggressive_path, 'slapping.txt', 2, 'Aggressive: Slapping', 2);

% Adjust the layout
sgtitle('Signal Plots from Normal and Aggressive Actions');
set(gcf, 'Position', [100, 100, 1000, 800]);  % Adjust figure size
