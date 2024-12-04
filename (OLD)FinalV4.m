%#ok<*GVMIS>
% Connect to the EV3 brick
%brick = ConnectBrick('GROUP4');
pause(2);
brick.SetColorMode(2, 2);  % Set the color sensor on port 2 to color mode
rightMotor = 'D';  % Right motor
leftMotor = 'B';   % Left motor
wallThreshold = 55;  % Distance threshold to detect walls 
checkpointDelay = 0.5; % Time to move forward after reaching Green
firstYellow = true;

% Time for a 90-degree turn
turnDurationL = 1; % Left turn
turnDurationR = 0.92; % Right turn
moveForwardDuration = 1.5; % Time to move forward after a turn

% Initialize keyboard control
global key;
InitKeyboard();

global finalGreen;
% Initialize the global variable if it's empty
if isempty(finalGreen)
    finalGreen = false; % Default value
end

% brick.MoveMotor(leftMotor, 92);
% brick.MoveMotor(rightMotor, 90);
% pause(2);

while true
    pause(0.1); % Pause for system stability

    colorCode = brick.ColorCode(2); 
    disp(['Color Code: ', num2str(colorCode)]); % Debug message for color

    if colorCode == 5  % RED color
        brick.StopMotor('BD', 'Brake');
        pause(3);  % Stop for 3 seconds
        brick.MoveMotor(leftMotor, 92);
        brick.MoveMotor(rightMotor, 90);

    elseif colorCode == 4  % YELLOW detected
        
        %If detecting Yellow for the first time and haven't been to green yet
        if firstYellow && ~finalGreen
            disp('Starting Positiong detected, Moving Forward...');
            brick.MoveMotor(leftMotor, 92);
            brick.MoveMotor(rightMotor, 90);

            pause(2);  % Keep Moving forward for 2 seconds

            firstYellow = false;  % Mark that the first yellow has been handled
            disp(['First Yellow: ', num2str(firstYellow)]);

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
        
        if brick.TouchPressed(1) 
            brick.MoveMotor('BD',-90);
            pause(0.25);
        end

        if leftDistance > wallThreshold
            % Turn left if no wall on the left
            % disp('Turning left...');
            % pause(1);
            % brick.MoveMotor(leftMotor, -90);
            % brick.MoveMotor(rightMotor, 90);
            % pause(turnDurationL);  % Turn left for the specified duration

            % brick.StopMotor('BD','Brake');

            brick.MoveMotorAngleRel(leftMotor, -95, 627, 'Brake'); 
            brick.MoveMotorAngleRel(rightMotor,95, 627, 'Brake');
            brick.WaitForMotor(leftMotor);

            colorCode = brick.ColorCode(2); 

            if colorCode == 5  % RED color
                brick.StopMotor('BD', 'Brake');
                pause(3);  % Stop for 3 seconds
                brick.MoveMotor(leftMotor, 92);
                brick.MoveMotor(rightMotor, 90);
            end
        else
            % Turn right if wall on the left
            % disp('Turning right...');
            % pause(1);
            % brick.MoveMotor(leftMotor, 80);
            % brick.MoveMotor(rightMotor, -80);
            % pause(turnDurationR);  % Turn right for the specified duration

            brick.MoveMotorAngleRel(leftMotor, 95, 565, 'Brake'); 
            brick.MoveMotorAngleRel(rightMotor,-95, 605, 'Brake');
            brick.WaitForMotor(rightMotor);

            brick.StopMotor('BD','Brake');

            colorCode = brick.ColorCode(2); 
            if colorCode == 5  % RED color
                brick.StopMotor('BD', 'Brake');
                pause(3);  % Stop for 3 seconds
                brick.MoveMotor(leftMotor, 92);
                brick.MoveMotor(rightMotor, 90);
            end
        end

        % Move forward after a turn
        disp('Moving forward after turn...');
        brick.MoveMotor(leftMotor, 92);
        brick.MoveMotor(rightMotor, 90);
        pause(moveForwardDuration);  % Move forward for the specified duration
        brick.StopMotor('BD', 'Brake');

        if colorCode == 5  % RED color
            brick.StopMotor('BD', 'Brake');
            pause(3);  % Stop for 3 seconds
            brick.MoveMotor(leftMotor, 92);
            brick.MoveMotor(rightMotor, 90);
        end

    elseif leftDistance < 4
        brick.MoveMotor(leftMotor, 92);
        brick.MoveMotor(rightMotor, -90);
        pause(0.5);    
    
    else
        % Move forward if no front wall
        brick.MoveMotor(leftMotor, 92);
        brick.MoveMotor(rightMotor, 90);

        if colorCode == 5  % RED color
            brick.StopMotor('BD', 'Brake');
            pause(3);  % Stop for 3 seconds
            brick.MoveMotor(leftMotor, 92);
            brick.MoveMotor(rightMotor, 90);
        end
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
