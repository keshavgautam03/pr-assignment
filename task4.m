%% Full Code to Load, Combine, Save, and Visualize Feature Data

% Define the output folder where the feature files are saved
output_folder = 'D:\feature';  % Change this path if necessary

% Get a list of all the feature files in the output folder
feature_files = dir(fullfile(output_folder, '*.txt'));

% Initialize an empty array to store the combined features
combined_features = [];

% Loop through each file and load its content
for i = 1:length(feature_files)
    % Get the full path of the feature file
    file_path = fullfile(output_folder, feature_files(i).name);
    
    try
        % Read the data from the file into a table
        features_table = readtable(file_path, 'Delimiter', '\t');
        
        % Convert the table to an array (if necessary)
        features_array = table2array(features_table);
        
        % Concatenate the data (features_array) to combined_features
        combined_features = [combined_features; features_array];
        
        % Display a message after processing each file
        fprintf('Processed file: %s\n', feature_files(i).name);
    catch ME
        fprintf('Error processing file %s: %s\n', feature_files(i).name, ME.message);
    end
end

% Check if combined_features is empty
if isempty(combined_features)
    error('No features were loaded. Please check the input files.');
end

% Display the first few rows of the combined features to confirm it's loaded correctly
disp('First few rows of the combined features:');
disp(combined_features(1:min(5, end), :));  % Displaying up to 5 rows

% Save the combined features to a CSV file using writematrix
output_combined_file = 'D:\feature\combined_features.csv';  % Adjust path as needed
writematrix(combined_features, output_combined_file);

% Print the path where the combined features are saved
fprintf('Combined features saved to: %s\n', output_combined_file);

%% Example Plotting - Visualizing Mean and Variance for Channel 1
% Check if 'Channel1_Mean' and 'Channel1_Variance' exist in the table
if size(combined_features, 2) >= 2  % Assuming at least 2 columns exist (for mean and variance)
   
    % Create a figure to visualize the features
    figure;
    
    % Plot the mean for Channel 1 (Assuming Channel1_Mean is the first column)
    subplot(1, 2, 1);
    plot(combined_features(:, 1));  % Assuming Channel1_Mean is in the first column
    title('Channel 1 Mean');
    xlabel('Sample');
    ylabel('Mean Value');
    
    % Plot the variance for Channel 1 (Assuming Channel1_Variance is the second column)
    subplot(1, 2, 2);
    plot(combined_features(:, 2));  % Assuming Channel1_Variance is in the second column
    title('Channel 1 Variance');
    xlabel('Sample');
    ylabel('Variance Value');
    
else
    fprintf('Channel1_Mean or Channel1_Variance not found in the combined features.\n');
end
