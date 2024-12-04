global key; %#ok<GVMIS>
InitKeyboard();
brick.SetColorMode(2, 2);  % Ensure the color sensor is set up

% O - up
% L - down
% Q - quit (returns to main script)

while true
    pause(0.1);  % Pause for system stability
    switch key
        case 'w'
            disp('FORWARD');
            brick.MoveMotor('B', 95);
            brick.MoveMotor('D', 95);
        case 's'
            disp('BACKWARD');
            brick.MoveMotor('B', -95);
            brick.MoveMotor('D', -95);
        case 'd'
            disp('RIGHT');
            brick.MoveMotor('B', 95);
            brick.MoveMotor('D', -95);
        case 'a'
            disp('LEFT');
            brick.MoveMotor('B', -95);
            brick.MoveMotor('D', 95);
        case 'o'
            disp('UP');
            brick.MoveMotor('C', 40); 
        case 'l'
            disp('DOWN');
            brick.MoveMotor('C', -40); 
        case 0
            disp('No Key Pressed!');
            brick.StopMotor('BDC', 'Coast');
        case 'q'
            disp('Exiting Remote Control Mode...');
            brick.StopMotor('BDC', 'Brake');
            run("FinalV4.m");
            break;
    end
end

CloseKeyboard();
