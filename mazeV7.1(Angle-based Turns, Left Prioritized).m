% Connect to the EV3 brick
%brick = ConnectBrick('GROUP4');
brick.SetColorMode(1, 2);  % Set the color sensor in color mode
rightMotor = 'B';  % Right motor
leftMotor = 'D';   % Left motor
turnAngle = 340;  % Motor angle for a 90-degree turn
wallThreshold = 30;  % Distance threshold to detect walls (in cm)
forwardDuration = 1;  % Time (in seconds) to move forward after detecting no wall
commitmentTime = 2;   % Time (in seconds) to commit to moving forward after turning
checkpointDelay = 0.5; % Time to move forward after reaching Green so that the car is fully inside the green zone
committed = false;    % Boolean used to make the robot commit to a turn and/or ignore the IR sensor values during a turn
commitStartTime = 0;  % Timestamp for when commitment started

while true
    % Check the current color
    colorCode = brick.ColorCode(1); 
    if colorCode == 5  % Red color
        brick.StopMotor('B', 'Brake');
        brick.StopMotor('D', 'Brake');

        pause(2);  % Stop for 2 seconds

        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 100);

    elseif colorCode == 3  % Green color 
        %brick.MoveMotor(leftMotor, 100);
        %brick.MoveMotor(rightMotor, 100);

        %pause(checkpointDelay);  % Move forward for a short time

        %brick.StopMotor('B', 'Brake');
        %brick.StopMotor('D', 'Brake');
        disp('Goal reached!');
        %break;
    end

    % Check left distance
    leftDistance = brick.UltrasonicDist(4); 

    % Check front wall
    if brick.TouchPressed(3) || (~committed && leftDistance > wallThreshold)
        % Wall in front OR no wall on left

        brick.StopMotor('B', 'Brake');
        brick.StopMotor('D', 'Brake');
        
        if ~committed && leftDistance > wallThreshold
            % Turn left if no wall on the left

            brick.MoveMotor(leftMotor, 100);
            brick.MoveMotor(rightMotor, 100);
            pause(forwardDuration);  % Move forward for a bit so that car turns into center of the opening on left

            brick.StopMotor('B', 'Brake');
            brick.StopMotor('D', 'Brake');

            brick.MoveMotorAngleRel(leftMotor, -100, turnAngle, 'Brake');            
            brick.MoveMotorAngleRel(rightMotor, 100, turnAngle, 'Brake');

            brick.WaitForMotor(leftMotor);
            brick.WaitForMotor(rightMotor);
            
            % Enter committed state
            committed = true;
            commitStartTime = tic;  % Start the timer for commitment

        else
            % Turn right if wall on the left or committed
            brick.MoveMotor(leftMotor, -100);
            brick.MoveMotor(rightMotor, -100);

            pause(0.1);
            
            brick.StopMotor('B', 'Brake');
            brick.StopMotor('D', 'Brake');
            
            brick.MoveMotorAngleRel(leftMotor, 100, turnAngle, 'Brake');            
            brick.MoveMotorAngleRel(rightMotor, -100, turnAngle, 'Brake');
            
            brick.WaitForMotor(leftMotor);
            brick.WaitForMotor(rightMotor);
        end
    else
        % Move forward if no front wall
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 100);
    end
    
    % Exit committed state after the commitment duration
    if committed && toc(commitStartTime) >= commitmentTime
        committed = false;
    end
end

% Disconnect from the EV3 brick after solving the maze
DisconnectBrick(brick);
