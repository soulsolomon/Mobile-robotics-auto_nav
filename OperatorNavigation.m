%----------------------------------------------------------------------%
%----------------------------Solomon Gugsa-----------------------------%

clc
clear
close all

% Modify with your ROS Master URI Address
ip = "http://192.168.233.130:11311";
rosinit(ip);

mysub = rossubscriber('/odom');
msg   = rosmessage(mysub)

mypub = rospublisher('cmd_vel');
msg2  = rosmessage(mypub);

scandata = rosmessage('sensor_msgs/LaserScan')

currentTime = 0;

x = 0;
y = 0;
a = 1;



%wait for event and publish, subscribe, plot
while(currentTime<3)
        while true
        k = waitforbuttonpress;
        % 97  A leftarrow
        % 100 D rightarrow
        % 115 S stop
        % 120 X backwards
        % 119 W forward
        
        value = double(get(gcf,'CurrentCharacter'));
        
            if (value == 119)
                
                msg2.Linear.X = 1;
                mypub.send(msg2)
                
            elseif (value == 120)
                
                msg2.Linear.X = -1;
                mypub.send(msg2);
                
            elseif (value == 97)
                
                msg2.Angular.Z = 1;
                mypub.send(msg2);
                
            elseif  (value == 100)
               
                msg2.Angular.Z = -1;
                mypub.send(msg2);
            end
            
        recvMsg = mysub.LatestMessage
            
            if (a >= 2)
               
               x = recvMsg.Pose.Pose.Position.X;
               y = recvMsg.Pose.Pose.Position.Y;
               a = a + 1;
       
            end
            
        a = a + 1;
        pause(.8)
            
            if (x > 1)
                
                plot(x,y,".-r")
                hold all; 
                plot(x,y,'b--o')
                legend('Robot Pose');
                
            end
        end

end
