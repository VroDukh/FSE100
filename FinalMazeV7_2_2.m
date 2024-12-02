% Connect to the EV3 brick
brick = ConnectBrick('GROUP4');
brick.SetColorMode(2, 2);  % Set the color sensor in color mode
rightMotor = 'D';  % Right motor
leftMotor = 'B';   % Left motor
wallThreshold = 30;  % Distance threshold to detect walls (in cm)
commitmentTime = 1.5;   % Time (in s) to commit to moving forward after turning
checkpointDelay = 0.5; % Time to move forward after reaching Green
turnDuration = 0.45;   % Time (in s) the robot will take to make a 90-degree turn %Values to try 0.4-0.61
committed = false;    % Boolean to make the robot commit to a turn
commitStartTime = 0;  % Timestamp for when commitment started

%brick.ResetUltrasonicSensor(3);  


global key;
InitKeyboard();

while true
    pause(0.1); % Pause for system stability

    % Check the current color
    colorCode = brick.ColorCode(1); 

    if colorCode == 5  % Red color
        brick.StopMotor('BD', 'Brake');
        pause(3);  % Stop for 3 seconds
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 100);

    elseif colorCode == 2 || colorCode == 3 || colorCode == 4  % Green,Blue or Yellow detected
        disp('Goal reached!');
        %pause(checkpointDelay);
        %brick.StopMotor('BD', 'Coast');
        %run("remoteControl.m");
        %break;
    end

    % Check left distance
    leftDistance = brick.UltrasonicDist(3); 

    % Check front wall
    if ~committed && (brick.TouchPressed(1) || leftDistance > wallThreshold)
        % Wall in front OR no wall on left
        brick.StopMotor('BD', 'Brake');
        
        if leftDistance > wallThreshold
            % Turn left if no wall on the left

            brick.MoveMotor(leftMotor, -100);
            brick.MoveMotor(rightMotor, -100);
            pause(0.1);
            brick.StopMotor('BD','Brake');

            disp('Turning left...');
            brick.MoveMotor(leftMotor, -100);
            brick.MoveMotor(rightMotor, 100);
            pause(turnDuration);  % Turn left for the specified duration
            brick.StopMotor('BD', 'Brake');
        else
            % Turn right if wall on the left

            brick.MoveMotor(leftMotor, -100);
            brick.MoveMotor(rightMotor, -100);
            pause(0.1);
            brick.StopMotor('BD','Brake');

            disp('Turning right...');
            brick.MoveMotor(leftMotor, 100);
            brick.MoveMotor(rightMotor, -100);
            pause(turnDuration);  % Turn right for the specified duration
            brick.StopMotor('BD', 'Brake');
        end

        % Enter committed state
        committed = true;
        commitStartTime = tic;  % Start the timer for commitment
        % Commited state just makes sure that after making the turn,
        % the robot actually goes forward into the turn and doesnt detect the area it came from as another possible turn


    elseif ~committed
        % Move forward if no front wall
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 100);
    end

    % Exit committed state after the commitment time has elapsed 
    if committed && toc(commitStartTime) >= commitmentTime
        committed = false;
    end
    % Ensures the robot doesnt remain in commited state and ignore turns
    
end

CloseKeyboard();
%DisconnectBrick(brick);
