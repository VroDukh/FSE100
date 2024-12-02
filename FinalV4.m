% Connect to the EV3 brick
brick = ConnectBrick('GROUP4');
brick.SetColorMode(2, 2);  % Set the color sensor on port 2 to color mode
rightMotor = 'D';  % Right motor
leftMotor = 'B';   % Left motor
wallThreshold = 40;  % Distance threshold to detect walls 
checkpointDelay = 0.5; % Time to move forward after reaching Green
firstYellow = true;

% Time for a 90-degree turn
turnDurationL = 0.65; % Left turn
turnDurationR = 0.63; % Right turn
moveForwardDuration = 2; % Time to move forward after a turn

% Initialize keyboard control
global key;
InitKeyboard();

global finalGreen;
% Initialize the global variable if it's empty
if isempty(finalGreen)
    finalGreen = false; % Default value
end


while true
    pause(0.1); % Pause for system stability

    colorCode = brick.ColorCode(2); 
    disp(['Color Code: ', num2str(colorCode)]); % Debug message for color

    if colorCode == 5  % RED color
        brick.StopMotor('BD', 'Brake');
        pause(3);  % Stop for 3 seconds
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 99);

    elseif colorCode == 4  % YELLOW detected
        
        %If detecting Yellow for the first time and haven't been to green yet
        if firstYellow && ~finalGreen
            disp('Starting Positiong detected, Moving Forward...');
            brick.MoveMotor(leftMotor, 100);
            brick.MoveMotor(rightMotor, 99);

            pause(2);  % Keep Moving forward for 2 seconds

            firstYellow = false;  % Mark that the first yellow has been handled

        elseif finalGreen
            disp('Final Position detected, Stopping...'); 
            brick.StopMotor('BD', 'Brake');
            pause(2);  % Pause for stability

            break;
        end

    elseif colorCode == 2  % BLUE detected
        disp('Goal reached!');
        brick.StopMotor('BD', 'Coast');
        run("remoteControl.m");  % Run the remote control script
        break;  % Exit the loop

    elseif colorCode == 3  % GREEN detected
        disp('Goal Reached!');
        brick.StopMotor('BD', 'Coast');
        run("remoteControl.m");  % Run the remote control script
        finalGreen = true;
        break;
    end

    % Check left distance
    leftDistance = brick.UltrasonicDist(3); 
    disp(['Left Distance: ', num2str(leftDistance)]); % Debug message for distance

    % Check front wall or open left side
    if brick.TouchPressed(1) || leftDistance > wallThreshold
        brick.StopMotor('BD', 'Brake');

        if leftDistance > wallThreshold
            % Turn left if no wall on the left
            disp('Turning left...');
            brick.MoveMotor(leftMotor, -100);
            brick.MoveMotor(rightMotor, 100);
            pause(turnDurationL);  % Turn left for the specified duration

            %Alternate Approach to Turning LEFT
            %brick.MoveMotorAngleRel(leftMotor, -90, 260, 'Brake'); 
            %brick.WaitForMotor(leftMotor);
            %brick.MoveMotorAngleRel(rightMotor,90, 260, 'Brake');
        else
            % Turn right if wall on the left
            disp('Turning right...');
            brick.MoveMotor(leftMotor, 100);
            brick.MoveMotor(rightMotor, -100);
            pause(turnDurationR);  % Turn right for the specified duration

            %Alternate Approach to Turning RIGHT
            %brick.MoveMotorAngleRel(leftMotor, 90, 260, 'Brake'); 
            %brick.WaitForMotor(leftMotor);
            %brick.MoveMotorAngleRel(rightMotor, -90, 260, 'Brake');
        end

        brick.StopMotor('BD', 'Brake');

        % Move forward after a turn
        disp('Moving forward after turn...');
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 99);
        pause(moveForwardDuration);  % Move forward for the specified duration
        brick.StopMotor('BD', 'Brake');
    else
        % Move forward if no front wall
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 99);
    end

    switch key
        case 'q'
            disp('Quit');
            brick.StopMotor('BD', 'Brake');
            break;
    end
end

CloseKeyboard();  % Close keyboard input
%DisconnectBrick(brick);  % Disconnect from the EV3 brick
