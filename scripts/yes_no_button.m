function userResponse = yes_no_button(question, title)

% Create the figure
fig = uifigure('Name', title, 'Position', [300, 300, 400, 200]);

% Display the question as a label
label = uilabel(fig, 'Text', question, 'Position', [50, 130, 300, 22], 'FontSize', 12);

% Create "Yes" button
yesButton = uibutton(fig, 'Text', 'Yes', 'Position', [100, 50, 75, 22], ...
    'ButtonPushedFcn', @(btn, event) yes_no_response('Yes'));

% Create "No" button
noButton = uibutton(fig, 'Text', 'No', 'Position', [250, 50, 75, 22], ...
    'ButtonPushedFcn', @(btn, event) yes_no_response('No'));

% Initialize userResponse as empty
userResponse = '';

% Define the callback function for buttons
    function yes_no_response(response)
        userResponse = response;
        delete(fig);
    end

% Wait for the user to make a choice
waitfor(fig);
end

