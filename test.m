brick = ConnectBrick('GROUP4');
brick.SetColorMode(1, 2);


%while 1
%    angle = brick.GyroAngle(2);
%    distance = brick.UltrasonicDist(3);
%    brick.MoveMotor('B',-95);
%    brick.MoveMotor('D',-100);
%    if brick.ColorCode(1) == 3
%        brick.StopMotor('BD','Brake');
%        fprintf("Turn Degrees = %d",angle);
%        break;        
%    elseif distance <= 20 || distance == 255
%        brick.StopMotor('BD','Brake');
%        fprintf("Turned Degrees = %d",angle);
%        break;
%    end
%end

%global key;
%InitKeyboard();
%brick.playTone(100, 300, 150);
%while 1
%    pause(0.1);
%    switch key
%    case 'w'
%        disp('Up Arrow Pressed!');
%        brick.MoveMotor('B',95);
%        brick.MoveMotor('D',95);
%    case 's'
%        disp('Down Arrow Pressed!');
%        brick.MoveMotor('B',-95);
%        brick.MoveMotor('D',-95);
%    case 'd'
%        disp('Right Arrow Pressed!');
%        brick.MoveMotor('B',-95);
%        brick.MoveMotor('D',95);
%    case 'a'
%        disp('Left Arrow Pressed!');
%        brick.MoveMotor('B',95);
%        brick.MoveMotor('D',-95);
%    case 'k'
%        %brick.MoveMotor('A',10);
%        disp('K Pressed!');
%        %pause(0.05);
%        %brick.StopMotor('A','Break')
%        brick.MoveMotorAngleRel('A', 15, 20, 'Coast');
%        brick.WaitForMotor('A');
%    case 'm'
%        %brick.MoveMotor('A',-10);
%        disp('M Pressed!');
%        %pause(0.05);
%        %brick.StopMotor('A','Break')
%        brick.MoveMotorAngleRel('A', -15, 20, 'Coast');
%        brick.WaitForMotor('A');
%    case 0
%        disp('No Key Pressed!');
%        brick.StopMotor('BD','Coast');
%    case 'x'
%        break;
%    end
%end
%CloseKeyboard();

brick.MoveMotor('B',65);
brick.MoveMotor('D',65);
while 1
    pause(0.1);  
    if brick.ColorCode(1) == 5
        %RED
        display(brick.ColorCode(1));
        brick.StopMotor('B');
        brick.StopMotor('D');
        pause(1);
        brick.MoveMotor('B',65);
        brick.MoveMotor('D',65);
    elseif brick.ColorCode(1) == 2
        %BLUE
        display(brick.ColorCode(1));
        brick.StopMotor('B');
        brick.StopMotor('D');
        pause(1);
        brick.beep();
        pause(0.5);
        brick.beep();
        brick.MoveMotor('B',65);
        brick.MoveMotor('D',65);
    elseif brick.ColorCode(1) == 3
        %GREEN
        display(brick.ColorCode(1));
        brick.StopMotor('B');
        brick.StopMotor('D');
        pause(1);
        brick.beep();
        pause(0.5);
        brick.beep();
        pause(0.5);
        brick.beep();
        %brick.MoveMotor('B',95);
        %brick.MoveMotor('D',95);
        break;
        % To stop the robot from constantly moving forward even after the
        % color sensors have been tested
    end
end

%brick.playTone(100, 300, 150);
DisconnectBrick(brick);
