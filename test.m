brick = ConnectBrick('GROUP4');
brick.SetColorMode(1, 2);
brick.GyroCalibrate(3);
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

global key;
InitKeyboard();
while 1
    pause(0.1);
    switch key
    case 'uparrow'
        disp('Up Arrow Pressed!');
        brick.MoveMotor('B',-95);
        brick.MoveMotor('D',-100);
    case 'downarrow'
        disp('Down Arrow Pressed!');
        brick.MoveMotor('B',95);
        brick.MoveMotor('D',100);
    case 'rightarrow'
        disp('Right Arrow Pressed!');
        brick.MoveMotor('B',-100);
        brick.MoveMotor('D',100);
    case 'leftarrow'
        disp('Left Arrow Pressed!');
        brick.MoveMotor('B',100);
        brick.MoveMotor('D',-100);
    case 0
        disp('No Key Pressed!');
        brick.StopMotor('BD','Brake');
    case 'q'
        break;
    end
end
CloseKeyboard();

brick.playTone(100, 300, 150);
DisconnectBrick(brick);
