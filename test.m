% Connect to the EV3 brick
brick = ConnectBrick('GROUP4');
brick.SetColorMode(1, 2);  % Set the color sensor in color mode
rightMotor = 'B';  % Right motor
leftMotor = 'D';   % Left motor
wallThreshold = 35;  % Distance threshold to detect walls (in cm)
turnAngle = 720;  % Motor angle for a 90-degree turn
maxSensorValue = 255;  % Sensors max value for unreliable readings

% Main loop to navigate the maze
while true
    % Check the color detected by the color sensor on Port 1
    colorCode = brick.ColorCode(1);  % Color sensor is at Port 1
    
    if colorCode == 4
        % YELLOW detected - Starting point, continue moving
        brick.MoveMotor(leftMotor, 50);
        brick.MoveMotor(rightMotor, 50);
        
    elseif colorCode == 3
        % GREEN detected - Goal reached
        brick.StopMotor(leftMotor);
        brick.StopMotor(rightMotor);
        disp('Goal reached!');
        %break;
    end
    
    % Step 1: Check for wall in front
    distanceFront = brick.UltrasonicDist(4);  % Ultrasonic sensor is at Port 4

    % Handle unreliable sensor readings
    if distanceFront == maxSensorValue
        distanceFront = Inf;  % Treat as no wall detected
    end

    if distanceFront > wallThreshold
        % If no wall in front, move forward
        brick.MoveMotor(leftMotor, 50);
        brick.MoveMotor(rightMotor, 50);
        continue;  % Skip side checks and keep moving forward
    end

    % If wall detected in front, stop motors
    brick.StopMotor(leftMotor);
    brick.StopMotor(rightMotor);

    % Step 2: Check for wall on the left side
    brick.MoveMotorAngleRel(leftMotor, -50, turnAngle, 'Brake');
    brick.MoveMotorAngleRel(rightMotor, 50, turnAngle, 'Brake');
    brick.WaitForMotor(leftMotor);
    distanceLeft = brick.UltrasonicDist(4);  % Ultrasonic sensor is at Port 4

    % Handle unreliable sensor readings
    if distanceLeft == maxSensorValue
        distanceLeft = Inf;  % Treat as no wall detected
    end
    
    % Turn back to face forward
    brick.MoveMotorAngleRel(leftMotor, 50, turnAngle, 'Brake');
    brick.MoveMotorAngleRel(rightMotor, -50, turnAngle, 'Brake');
    brick.WaitForMotor(leftMotor);

    % Step 3: Check for wall on the right side
    brick.MoveMotorAngleRel(leftMotor, 50, turnAngle, 'Brake');
    brick.MoveMotorAngleRel(rightMotor, -50, turnAngle, 'Brake');
    brick.WaitForMotor(leftMotor);
    distanceRight = brick.UltrasonicDist(4);  % Ultrasonic sensor is at Port 4

    % Handle unreliable sensor readings
    if distanceRight == maxSensorValue
        distanceRight = Inf;  % Treat as no wall detected
    end

    % Turn back to face forward
    brick.MoveMotorAngleRel(leftMotor, -50, turnAngle, 'Brake');
    brick.MoveMotorAngleRel(rightMotor, 50, turnAngle, 'Brake');
    brick.WaitForMotor(leftMotor);

    % Step 4: Decide movement based on distances
    if distanceLeft > wallThreshold
        % No wall on the left, turn left
        brick.MoveMotorAngleRel(leftMotor, -50, turnAngle, 'Brake');
        brick.MoveMotorAngleRel(rightMotor, 50, turnAngle, 'Brake');
        brick.WaitForMotor(leftMotor);
        
    elseif distanceRight > wallThreshold
        % No wall on the right, turn right
        brick.MoveMotorAngleRel(leftMotor, 50, turnAngle, 'Brake');
        brick.MoveMotorAngleRel(rightMotor, -50, turnAngle, 'Brake');
        brick.WaitForMotor(leftMotor);
        
    else
        % Dead end (walls on left, front, and right), turn around
        brick.MoveMotorAngleRel(leftMotor, 50, 2 * turnAngle, 'Brake');  % Turn 180 degrees
        brick.MoveMotorAngleRel(rightMotor, -50, 2 * turnAngle, 'Brake');
        brick.WaitForMotor(leftMotor);
    end

    % Move forward briefly after making a turn
    brick.MoveMotor(leftMotor, 50);
    brick.MoveMotor(rightMotor, 50);
    pause(0.5);  % Adjust this to control how far it moves after turning
end

% Disconnect from the EV3 brick after the maze is solved
DisconnectBrick(brick);
