global key;
InitKeyboard();
brick.SetColorMode(2, 2);

% O - up
% L - down
% q - quit

while 1
    pause(0.1);
    switch key
    case 'w'
        disp('FORWARD');
        brick.MoveMotor('B',95);
        brick.MoveMotor('D',95);
    case 's'
        disp('BACKWARD');
        brick.MoveMotor('B',-95);
        brick.MoveMotor('D',-95);
    case 'd'
        disp('RIGHT');
        brick.MoveMotor('B',95);
        brick.MoveMotor('D',-95);
    case 'a'
        disp('LEFT');
        brick.MoveMotor('B',-95);
        brick.MoveMotor('D',95);
    case 'o'
        brick.MoveMotor('C', 40); 
        disp('UP');
    case 'l'
        brick.MoveMotor('C', -40); 
        disp('DOWN');
    case 0
        disp('No Key Pressed!');
        brick.StopMotor('BDC','Coast');
    case 'q'
        brick.StopMotor('ADB', 'Brake');
        run("FinalMazeV7_2_2.m");
        break;
    end
end
CloseKeyboard();
   
