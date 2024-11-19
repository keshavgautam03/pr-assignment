% Define the paths for feature and label files
feature_dir = 'D:\feature'; % Path to feature directory
label_file_path = 'D:\datasets\sub1\Aggressive\txt'; % Path to labels file (corrected)

% Load feature data
all_features = {}; 
feature_files = dir(fullfile(feature_dir, '*.txt'));
for i = 1:length(feature_files)
    file_name = feature_files(i).name;
    file_path = fullfile(feature_dir, file_name);
    try
        fid = fopen(file_path, 'r');
        lines = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);
        lines = lines{1};
        
        % Skip header if necessary and convert to numeric data
        if isempty(str2double(strsplit(lines{1})))
            lines = lines(2:end);
        end
        feature_data = [];
        for j = 1:length(lines)
            feature_data = [feature_data; str2double(strsplit(lines{j}))'];
        end
        all_features{end + 1} = feature_data;
    catch ME
        fprintf('Error reading file %s: %s\n', file_name, ME.message);
    end
end

% Load labels (ensure the file exists and contains numeric data)
all_labels = load(label_file_path); % Ensure the file contains numeric data

% Determine the total number of samples
total_samples = sum(cellfun(@(x) size(x, 1), all_features));

% Create a combined feature matrix
all_features_combined = vertcat(all_features{:});

% Parameters
num_mc_runs = 10; % Number of Monte Carlo runs
max_classes = 19; % Maximum number of classes to test
accuracy_results = zeros(num_mc_runs, max_classes - 1); % Store accuracy results for each class combination and MC run

% For each number of classes (from 2 to 19)
for num_classes = 2:max_classes
    % Generate all possible class combinations (nchoosek)
    class_combos = nchoosek(1:20, num_classes);
    num_combos = size(class_combos, 1); % Total number of combinations
    
    % Select 10 random combinations
    selected_combos = class_combos(randi(num_combos, 10, 1), :);
    
    % Monte Carlo runs for each selected class combination
    for mc = 1:num_mc_runs
        % Initialize accuracy for this Monte Carlo run
        mc_accuracy = zeros(1, 10); 
        
        for combo_idx = 1:10
            % Extract selected class labels
            selected_classes = selected_combos(combo_idx, :);
            
            % Extract the features and labels for the selected classes
            selected_indices = ismember(all_labels, selected_classes);
            selected_features = all_features_combined(selected_indices, :);
            selected_labels = all_labels(selected_indices);
            
            % Cross-validation setup (e.g., 10-fold cross-validation)
            cv = cvpartition(length(selected_labels), 'KFold', 10);
            
            % Store cross-validation accuracies for this combination
            fold_accuracies = zeros(cv.NumTestSets, 1);
            
            for fold = 1:cv.NumTestSets
                % Split the data into training and testing
                train_idx = cv.training(fold);
                test_idx = cv.test(fold);
                
                % Train k-NN classifier (choose k=3 for example)
                mdl = fitcknn(selected_features(train_idx, :), selected_labels(train_idx), 'NumNeighbors', 3);
                
                % Test the classifier on the validation set
                predicted_labels = predict(mdl, selected_features(test_idx, :));
                
                % Compute accuracy for this fold
                fold_accuracies(fold) = sum(predicted_labels == selected_labels(test_idx)) / length(test_idx);
            end
            
            % Store the mean accuracy for this combination and MC run
            mc_accuracy(combo_idx) = mean(fold_accuracies);
        end
        
        % Store results for this Monte Carlo run
        accuracy_results(mc, num_classes - 1) = mean(mc_accuracy); % Store the average of 10 combos
    end
end

% Plot the heatmap of accuracy vs number of classes and Monte Carlo runs
figure;
imagesc(accuracy_results);
colorbar;
xlabel('Number of Classes');
ylabel('Monte Carlo Run');
title('Cross-validation Accuracy Heatmap');
xticks(1:max_classes-1);
xticklabels(2:max_classes);
yticks(1:num_mc_runs);
yticklabels(1:num_mc_runs);
axis tight;

% Evaluate and plot the mean accuracy across Monte Carlo runs
mean_accuracies = mean(accuracy_results, 1);

figure;
plot(2:max_classes, mean_accuracies, '-o');
xlabel('Number of Classes');
ylabel('Mean Accuracy');
title('Mean Accuracy vs Number of Classes');
grid on;
