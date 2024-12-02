% Connect to the EV3 brick
%brick = ConnectBrick('GROUP4');
brick.SetColorMode(2, 2);  % Set the color sensor in color mode
rightMotor = 'B';  % Right motor
leftMotor = 'D';   % Left motor
wallThreshold = 30;  % Distance threshold to detect walls (in cm)\
commitmentTime = 2;   % Time (in s) to commit to moving forward after turning, prevents robot from continously tunring
checkpointDelay = 0.5; % Time to move forward after reaching Green so that the robot is fully inside the green zone
turnDuration = 0.5;   % Time (in s) the robot will take to make a 90 degree turn
committed = false;    % Boolean used to make the robot commit to a turn and/or ignore the IR sensor values during a turn
commitStartTime = 0;  % Timestamp for when commitment started

global key;
InitKeyboard();

while true
    pause(0.1); %Pause for system stability
    % Check the current color
    colorCode = brick.ColorCode(1); 
    if colorCode == 5  % Red color
        brick.StopMotor('BD', 'Brake');

        pause(2);  % Stop for 2 seconds

        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 100);

    elseif colorCode == 3  % Green color
        disp('Goal reached!');
        %pause(checkpointDelay);  % Move forward for a short time
        %brick.StopMotor('BD', 'Brake');
        %break;
    end

    % Check left distance
    leftDistance = brick.UltrasonicDist(3); 

    % Check front wall
    if brick.TouchPressed(1) || (~committed && leftDistance > wallThreshold)
        % Wall in front OR no wall on left

        brick.StopMotor('BD', 'Brake');
        
        if ~committed && leftDistance > wallThreshold
            % Turn left if no wall on the left & the robot is currently not going through a turn already(committed)

            brick.MoveMotor(leftMotor, 100);
            brick.MoveMotor(rightMotor, 100);

            %%pause(forwardDuration);  % Move forward for a bit so that car turns into center of the opening on left

            brick.StopMotor('BD', 'Brake');

            % Turn left for the specified turnDuration
            brick.MoveMotor(leftMotor,-100);
            brick.MoveMotor(rightMotor,100);

            pause(turnDuration);  % Keep turning left 

            brick.StopMotor('BD', 'Brake');
            
            % Enter committed state
            committed = true;
            commitStartTime = tic;  % Start the timer for commitment

        else
            % Turn right if wall on the left or committed
            brick.MoveMotor(leftMotor,100);
            brick.MoveMotor(rightMotor,-100);
            pause(turnDuration);  % Turn right for the specified duration
            brick.StopMotor('BD', 'Brake');
        end
    else
        % Move forward if no front wall
        brick.MoveMotor(leftMotor, 100);
        brick.MoveMotor(rightMotor, 100);
    end
    
    % Exit committed state after a couple of seconds
    if committed && toc(commitStartTime) >= commitmentTime
        committed = false;
    end
end

% Disconnect from the EV3 brick after solving the maze
DisconnectBrick(brick);
