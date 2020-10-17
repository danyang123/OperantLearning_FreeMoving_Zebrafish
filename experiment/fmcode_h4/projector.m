screen_coordinate=[1921 0 2945 768];
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
% load('G:\LDY\different patter of light intensity\Img.mat');
% Img1 = Img{1};
% Img2 = Img{2};
ImgTexture = zeros(1,16);
[window, ~] = PsychImaging('OpenWindow', screenNumber,[0,0,0],screen_coordinate);
Screen('DrawingFinished', window);
Screen('Preference', 'SkipSyncTests', 0);
ifi = Screen('GetFlipInterval', window);
for i = 1:16
    ImgTexture(i) = Screen('MakeTexture', window, Img{i});
end
Screen('DrawTexture', window, ImgTexture(1), [], [], 0);   Screen('Flip', window);



Screen('FillRect', window, [0 0 0]);
Screen('DrawingFinished', window);
Screen('Flip', window);
