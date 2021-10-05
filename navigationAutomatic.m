clc
clear all
close all

% Modify with your ROS Master URI Address
ip = "http://192.168.233.130:11311";
rosinit(ip);

%map from rosbag
load('myNewocc.mat')
map = occupancyMap(simpleMap);
inflate(map, 0.05);





%start&goal pose
Xdot        = msg1.Pose.Pose.Position.X;
Ydot        = msg1.Pose.Pose.Position.Y;
thetadot    = msg1.Pose.Pose.Orientation;
thetadott   = quat2eul([thetadot.W thetadot.X thetadot.Y thetadot.Z]);

startLocation = [Xdot, Ydot]
endLocation = [2.5 -6];

prm.ConnectionDistance = 2;
path = findpath(prm, startLocation, endLocation);
show(prm)

%initial location
robotInitialLocation = path(1,:);
robotGoal = path(end,:);

%initial orientation
initialOrientation = thetadott(1);

%Define the current pose for the robot [x y theta]
robotCurrentPose = [robotInitialLocation initialOrientation]'

robot = differentialDriveKinematics("TrackWidth", .5, "VehicleInputs", "VehicleSpeedHeadingRate");
controller = controllerPurePursuit;
controller.Waypoints = path;
controller.DesiredLinearVelocity = 0.3;
controller.MaxAngularVelocity = 2;
controller.LookaheadDistance = 0.2;

%Compute distance to the goal location
distanceToGoal = norm(robotInitialLocation - robotGoal);
goalRadius = 0.3; %Define a goal radius


% Initialize the simulation loop
sampleTime = 0.1;
vizRate = rateControl(1/sampleTime);

% Determine vehicle frame size to most closely represent vehicle with plotTransforms
frameSize = robot.TrackWidth/0.8;

% Initialize the figure
figure 
 
while( distanceToGoal > goalRadius )
    
    
    
    
    % Update the current pose
    odomsub2            = rossubscriber('/odom');
    msg1                = receive(odomsub2);
    x                   = msg1.Pose.Pose.Position.X;
    y                   = msg1.Pose.Pose.Position.Y;
    theta               = msg1.Pose.Pose.Orientation;
    Thetadot            = quat2eul([theta.W theta.X theta.Y theta.Z]);
    
    
    % Compute the controller outputs, i.e., the inputs to the robot
    [v, omega] = controller(robotCurrentPose);
    
    % Get the robot's velocity using controller inputs
    vel = derivative(robot, robotCurrentPose, [v omega]);
    
    
    robotCurrentPose    = [x, y, Thetadot(1)]'
    
    robotCurrentPose = robotCurrentPose + vel*sampleTime;
                mypub           = rospublisher('cmd_vel');
                msg2            = rosmessage(mypub);            
                msg2.Linear.X   = v;
                msg2.Angular.Z  = omega;
                mypub.send(msg2);
                
                
                
    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal(:));
    
    % Update the plot
    hold off
    show(prm);
   
    hold all

    % Plot path each instance so that it stays persistent while robot mesh
    % moves
    plot(path(:,1), path(:,2),"k--d")
    
    % Plot the path of the robot as a set of transforms
    plotTrVec = [robotCurrentPose(1:2); 0];
    plotRot = axang2quat([0 0 1 robotCurrentPose(3)]);
    plotTransforms(plotTrVec', plotRot, 'MeshFilePath', 'groundvehicle.stl', 'Parent', gca, "View","2D", "FrameSize", frameSize);
    light;
    
    
%     xlim([-4 4])
%     ylim([-4 3])
    
    waitfor(vizRate);
end
