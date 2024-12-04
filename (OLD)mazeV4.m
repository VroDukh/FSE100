% Connect to the EV3 brick
%brick = ConnectBrick('GROUP4');
brick.SetColorMode(1, 2);  % Set the color sensor in color mode
rightMotor = 'B';  % Right motor
leftMotor = 'D';   % Left motor
turnAngle = 340;  % Motor angle for a 90-degree turn
%backUpDistance = -180;  % Backward motion to avoid a wall
wallThreshold = 30;  % Distance threshold to detect walls (in cm)
%maxSensorValue = 255;  % Sensors max value for unreliable readings

while true
    % Check the current color
    colorCode = brick.ColorCode(1);  % Color sensor is at Port 1
    if colorCode == 4
        % Yellow: Starting point
        %brick.MoveMotor(leftMotor, 100);
        %brick.MoveMotor(rightMotor, 100);
    elseif colorCode == 3
        % Green: Goal reached
        %brick.StopMotor(leftMotor);
        %brick.StopMotor(rightMotor);
        %disp('Goal reached!');
        %break;
    end

    % Check for front wall using the touch sensor
    if brick.TouchPressed(3)  % Touch sensor is at Port 3
        % Wall detected in front
        brick.StopMotor('B','Brake');
        brick.StopMotor('D','Brake');
        
        % Check distance on the left
        leftDistance = brick.UltrasonicDist(4);  % Ultrasonic sensor on left (Port 4)
        %if leftDistance == maxSensorValue
        %    leftDistance = Inf;  % Treat max value as no wall
        %end

        if leftDistance > wallThreshold
            % Turn left if no wall on the left
            brick.MoveMotor(leftMotor, -100);
            brick.MoveMotor(rightMotor, -100);
            pause(0.1);
            brick.StopMotor('B','Brake');
            brick.StopMotor('D','Brake');
            brick.MoveMotorAngleRel(leftMotor, -100, turnAngle, 'Brake');            
            brick.MoveMotorAngleRel(rightMotor, 100, turnAngle, 'Brake');
            brick.WaitForMotor(leftMotor);
            brick.WaitForMotor(rightMotor);
        else
            % Turn right
            brick.MoveMotor(leftMotor, -100);
            brick.MoveMotor(rightMotor, -100);
            pause(0.1);
            brick.StopMotor('B','Brake');
            brick.StopMotor('D','Brake');
            brick.MoveMotorAngleRel(leftMotor, 100, turnAngle, 'Brake');            
            brick.MoveMotorAngleRel(rightMotor, -100, turnAngle, 'Brake');
            brick.WaitForMotor(leftMotor);
            brick.WaitForMotor(rightMotor);
            

            % Check front wall again using touch sensor
            %if brick.TouchPressed(3)
                % Wall detected on the right, back up again
            %    brick.MoveMotorAngleRel(leftMotor, -70, backUpDistance, 'Brake');
            %    brick.MoveMotorAngleRel(rightMotor, -70, backUpDistance, 'Brake');
            %    brick.WaitForMotor(leftMotor);
            %end
        end
    else
        % Move forward if no front wall
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 100);
    end
end

% Disconnect from the EV3 brick after solving the maze
DisconnectBrick(brick);
