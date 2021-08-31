import rospy

from sensor_msgs.msg import LaserScan
from geometry_msgs.msg import Twist

pub = None

def reg_laser(msg):
    Def_reg = {
        'R':  min(min(msg.ranges[0:71]), 3.5),
        'F-R': min(min(msg.ranges[72:143]), 3.5),
        'F':  min(min(msg.ranges[144:216]), 3.5),
        'F-L':  min(min(msg.ranges[217:289]), 3.5),
        'L':   min(min(msg.ranges[290:360]), 3.5),
    }

    detect_obj(Def_reg)


def detect_obj(Def_reg):
    msg = Twist()
    linear_x = 0
    angular_z = 0

    Curr_state = ''

    if Def_reg['F'] > 1 and Def_reg['F-L'] > 1 and Def_reg['F-R'] > 1:
        Curr_state = 'No Collusion'
        linear_x = 1
        angular_z = 0
    elif Def_reg['F'] < 1 and Def_reg['F'] > 1 and Def_reg['F-R'] > 1:
        Curr_state = 'Front Collusion'
        linear_x = 0
        angular_z = -1
    elif Def_reg['F'] > 1 and Def_reg['F-L'] > 1 and Def_reg['F-R'] < 1:
        Curr_state = 'Front-Right Collusion'
        linear_x = 0
        angular_z = -1
    elif Def_reg['F'] > 1 and Def_reg['F-L'] < 1 and Def_reg['F-R'] > 1:
        Curr_state = 'Front-Left Collusion'
        linear_x = 0
        angular_z = 1
    elif Def_reg['F'] < 1 and Def_reg['F-L'] > 1 and Def_reg['F-R'] < 1:
        Curr_state = 'Front and Front-right Collusion'
        linear_x = 0
        angular_z = -1
    elif Def_reg['F'] < 1 and Def_reg['F-L'] < 1 and Def_reg['F-R'] > 1:
        Curr_state = 'Front and Front-left Collusion'
        linear_x = 0
        angular_z = 1
    elif Def_reg['F'] < 1 and Def_reg['F-L'] < 1 and Def_reg['F-R'] < 1:
        Curr_state = 'Front and Front-left and front-right Collusion'
        linear_x = 0
        angular_z = -1
    elif Def_reg['F'] > 1 and Def_reg['F-L'] < 1 and Def_reg['F-L'] < 1:
        Curr_state = 'Front-left and Front-right Collusiong'
        linear_x = 0
        angular_z = -1
    else:
        Curr_state = 'Error'
        rospy.loginfo(Def_reg
)
        linear_x = 1

    rospy.loginfo(Curr_state)
    msg.linear.x = linear_x
    msg.angular.z = angular_z
    pub.publish(msg)






def main():
    global pub

    rospy.init_node('scanlaser')

    pub = rospy.Publisher('/cmd_vel', Twist, queue_size=1)

    sub = rospy.Subscriber('/scan', LaserScan, reg_laser)

    rospy.spin()

if __name__ == '__main__':
    main()