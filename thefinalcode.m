% Connect to the EV3 brick
% brick = ConnectBrick('GROUP4');
% Set up the sensors and motors
brick.SetColorMode(2, 3); % Set color sensor on Port 2 to ColorCode mode
% Constants
RIGHT_WALL_DIST = 70; % cm (distance for right turn)
DELAY_RED_STOP = 1.75; % seconds
TURN_DURATION = 2.45; % seconds for 90° turn (adjust experimentally)
BACKUP_DURATION = 1; % seconds to back up
SEARCH_COLORS = [2, 3, 4]; % Blue -> Green -> Yellow
KEYBOARD_STOP_KEY = 'q'; % Key to restart maze-solving
RIGHT_MOTOR_SPEED = 56; % Speed for right motor (%)
LEFT_MOTOR_SPEED = 58; % Speed for left motor (%)
TURN_SPEED = 25; % Speed for turning (%)
FORWARD_AFTER_TURN_DURATION = 1.3; % Adjustable duration for moving forward after a turn (in seconds)
distance = 0;   
% Variables
currentTargetColor = SEARCH_COLORS(1);
isUserControl = false;
lastRightTurnTime = -1; % Time of the last right turn (initialized to allow the first right turn)
% Main algorithm
disp('Starting the maze-solving algorithm.');
% Initialize the flag
redStripeHandled = false;
while true
   % Check if in user control mode
   if isUserControl
       disp('User control active. Use keyboard to control the robot.');
       userControl(brick, KEYBOARD_STOP_KEY);
       isUserControl = false;
       continue;
   end
   % Check for red stripe
   color = brick.ColorCode(2);
   if color == 5 % Red stripe detected
       if ~redStripeHandled
           disp('Red stripe detected. Pausing for 2 seconds.');
           brick.StopMotor('AD', 'Coast');
           pause(DELAY_RED_STOP);
           % Move forward to clear the stripe
           disp('Moving forward to clear the red stripe.');
           move(brick, LEFT_MOTOR_SPEED, RIGHT_MOTOR_SPEED, .8); % Adjust duration as needed
           % Mark red stripe as handled
           redStripeHandled = true;
       end
       continue;
   else
       % Reset the redStripeHandled flag if no red stripe is detected
       redStripeHandled = false;
   end
   % Check for target color
   if color == currentTargetColor
       disp(['Target color found: ', num2str(currentTargetColor)]);
       if currentTargetColor == SEARCH_COLORS(end)
           disp('Final target reached. Stopping the algorithm.');
           brick.StopMotor('AD', 'Coast');
           break;
       end
       % Move to next target color and enter user control mode
       currentTargetColor = SEARCH_COLORS(find(SEARCH_COLORS == currentTargetColor) + 1);
       isUserControl = true;
       continue;
   end
   % Check touch sensor
   if brick.TouchPressed(4) == 1
       disp('Obstacle detected! Reversing and turning left.');
       move(brick, -LEFT_MOTOR_SPEED, -RIGHT_MOTOR_SPEED, BACKUP_DURATION);
       turn(brick, TURN_SPEED, 'left', TURN_DURATION);
       continue;
   end
   % Check for open right turn
   distance = brick.UltrasonicDist(3); % Ultrasonic sensor on Port 3
disp(distance);
  
currentTime = toc; % Get the current time
if distance >= RIGHT_WALL_DIST
   if currentTime - lastRightTurnTime >= 6  % Check if enough time has passed
       disp('Right wall detected within range. Moving forward for 1.5 seconds before turning right.');
       % Move forward for 1.5 seconds before the right turn
       move(brick, LEFT_MOTOR_SPEED, RIGHT_MOTOR_SPEED, 1.5);
       % Perform the right turn
       disp('Turning right.');
       startTime = tic; % Record the start time of the turn
       move(brick, LEFT_MOTOR_SPEED, -RIGHT_MOTOR_SPEED, 1.2);
       redStripeHandled = false; % Reset red stripe flag
       % Initiate the right turn here (update lastRightTurnTime immediately)
       lastRightTurnTime = currentTime;  % Update immediately after starting the right turn
      
       while toc(startTime) < TURN_DURATION
           disp('Moving forward.');
           move(brick, LEFT_MOTOR_SPEED, RIGHT_MOTOR_SPEED, 1.69);
           % Check for red stripe during the turn
           color = brick.ColorCode(2);
           if color == 5 && ~redStripeHandled % Red stripe detected
               disp('Red stripe detected during turn. Pausing for 2 seconds.');
               brick.StopMotor('AD', 'Coast');
               pause(DELAY_RED_STOP);
               redStripeHandled = true; % Mark red stripe as handled
           end
          
           % Check for obstacles during the turn
           if brick.TouchPressed(4) == 1
               disp('Obstacle detected during turn! Reversing and turning left.');
               move(brick, -LEFT_MOTOR_SPEED, -RIGHT_MOTOR_SPEED, BACKUP_DURATION);
               turn(brick, TURN_SPEED, 'left', TURN_DURATION);
               break; % Exit the loop after handling obstacle
           end
           % Optional: You can insert more checks or control tasks here (e.g., color detection)
           pause(0.1); % Small delay to prevent over-polling
       end
   else
       disp('Waiting for 2 seconds before next right turn.');
   end
else
   disp('Moving forward.');
   % Continue moving forward if no right turn condition is met
   if moveWithColorCheck(brick, LEFT_MOTOR_SPEED, RIGHT_MOTOR_SPEED, 0.1) == 5
       disp('Red stripe detected while moving. Pausing for 2 seconds.');
       brick.StopMotor('AD', 'Coast');
       pause(DELAY_RED_STOP);
   end
end
end
% Disconnect the EV3 brick
% DisconnectBrick(brick);
% Function to move forward or backward while checking for color
function detectedColor = moveWithColorCheck(brick, leftSpeed, rightSpeed, duration)
   brick.MoveMotor('A', rightSpeed);
   brick.MoveMotor('D', leftSpeed);
   detectedColor = 0;
   tStart = tic;
   while toc(tStart) < duration
       detectedColor = brick.ColorCode(2);
       if detectedColor == 5 % Red
           break;
       end
       pause(0.1); % Short pause to avoid over-polling
   end
   brick.StopMotor('AD', 'Coast');
end
% Function to move forward or backward
function move(brick, leftSpeed, rightSpeed, duration)
   brick.MoveMotor('A', rightSpeed);
   brick.MoveMotor('D', leftSpeed);
   pause(duration);
   brick.StopMotor('AD', 'Coast');
end
% Function to turn left or right
function turn(brick, speed, direction, duration)
   if strcmp(direction, 'left')
       % Turn left: left motor backward, right motor forward
       brick.MoveMotor('D', -speed); % Left motor reverse
       brick.MoveMotor('A', speed);  % Right motor forward
   else
       % Turn right: left motor forward, right motor backward
       brick.MoveMotor('D', speed);  % Left motor forward
       brick.MoveMotor('A', -speed); % Right motor reverse
   end
   pause(duration);
   brick.StopMotor('AD', 'Coast');
end
% Function to handle user control
function userControl(brick, stopKey)
  global key; %#ok<GVMIS>
InitKeyboard();
brick.SetColorMode(2, 3);  % Ensure the color sensor is set up
% O - up
% L - down
% Q - quit (returns to main script)
while true
   pause(0.1);  % Pause for system stability
   switch key
       case 'w'
           disp('FORWARD');
           brick.MoveMotor('A', 45);
           brick.MoveMotor('D', 45);
       case 's'
           disp('BACKWARD');
           brick.MoveMotor('A', -45);
           brick.MoveMotor('D', -45);
       case 'a'
           disp('RIGHT');
           brick.MoveMotor('A', 45);
           brick.MoveMotor('D', -45);
       case ['d' ...
               '']
           disp('LEFT');
           brick.MoveMotor('A', -45);
           brick.MoveMotor('D', 45);
       case 'o'
           disp('UP');
           brick.MoveMotor('B', 10);
       case 'l'
           disp('DOWN');
           brick.MoveMotor('B', -10);
       case 0
           disp('No Key Pressed!');
           brick.StopMotor('AD', 'Coast');
           brick.StopMotor('B', 'Coast');
       case 'q'
           disp('Exiting Remote Control Mode...');
           brick.StopMotor('AD', 'Brake');
           brick.StopMotor('B', 'Brake');
          break;
  end
end
CloseKeyboard();
end

