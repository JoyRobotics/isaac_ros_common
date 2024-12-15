#!/bin/bash
#
# Copyright (c) 2021, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.
PROJECT=joy_robot

# Build ROS dependency & diablo_robot dependency
echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
echo "source ${ISAAC_ROS_WS}/install/setup.bash" >> ~/.bashrc
echo "source /opt/deploy/$PROJECT/install/setup.bash" >> ~/.bashrc
echo "sudo chmod 666 /dev/ttyTH*" >> ~/.bashrc
echo "sudo chmod 666 /dev/ttyUS*" >> ~/.bashrc
echo "set -g mouse on" >> ~/.tmux.conf

source ~/.bashrc


# supervisor
for file in /opt/deploy/$PROJECT/deploy_scripts/supervisor/*; do
  sudo ln -s "$file" /etc/supervisor/conf.d/
done
#sudo supervisord -c /etc/supervisor/supervisord.conf

# start log tmux
tmux new-session -d -s joy_log

# 创建窗口和面板
tmux split-window -h -t joy_log
tmux split-window -v -t joy_log:0.1
tmux split-window -v -t joy_log:0.0
tmux split-window -v -t joy_log:0.0
tmux split-window -v -t joy_log:0.2
tmux split-window -v -t joy_log:0.4
tmux split-window -v -t joy_log:0.6
# tmux new-window -t joy_log

# 等待窗口和面板创建完成
sleep 3

# 发送命令到各个面板
LOG_DIR=/var/log/$PROJECT
tmux send-keys -t dia_log:0.0 'tail -f /var/log/joy_robot/1_navigation.log' C-m
tmux send-keys -t dia_log:0.1 'tail -f /var/log/joy_robot/2_perceptor.log' C-m
tmux send-keys -t dia_log:0.2 'tail -f /var/log/joy_robot/3_lidar_mapping.log' C-m
tmux send-keys -t dia_log:0.3 'tail -f /var/log/joy_robot/4_teleop.log' C-m
tmux send-keys -t dia_log:0.4 'tail -f /var/log/joy_robot/5_*.log' C-m
tmux send-keys -t dia_log:0.5 'sudo supervisorctl' C-m
tmux send-keys -t dia_log:0.6 'tail -f /var/log/joy_robot/7_*.log' C-m
tmux send-keys -t dia_log:0.7 'tail -f /var/log/joy_robot/8_*.log' C-m
# tmux send-keys -t dia_log:1.0 'tail -f /var/log/joy_robot/9_*.log' C-m

# 附加到会话
# tmux attach-session -t dia_log

# Restart udev daemon
sudo service udev restart

$@
