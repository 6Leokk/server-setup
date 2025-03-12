#!/bin/bash

# --- 获取脚本语言 ---
script_lang="${SCRIPT_LANG}"

# --- 函数定义 ---
get_localized_message() {
    local lang="${script_lang:-${LANG%.*}}"
    local message_id="$1"
    local default_message=""

    case $lang in
        zh_CN*)
            case $message_id in
                docker_installing) default_message="正在安装 Docker...";;
                docker_install_success) default_message="Docker 安装完成。";;
                docker_install_fail) default_message="Docker 安装失败！";;
                docker_start_daemon) default_message="正在启动 Docker 服务...";;
                docker_start_success) default_message="Docker 服务启动成功。";;
                docker_start_fail) default_message="Docker 服务启动失败！";;
                docker_enable_daemon) default_message="正在设置 Docker 服务开机自启...";;
                docker_enable_success) default_message="Docker 服务已设置为开机自启。";;
                docker_enable_fail) default_message="设置 Docker 服务开机自启失败！";;
                docker_add_user_group) default_message="正在将当前用户添加到 docker 用户组...";;
                docker_add_user_success) default_message="当前用户已添加到 docker 用户组，请注销并重新登录以使更改生效。";;
                docker_add_user_fail) default_message="将当前用户添加到 docker 用户组失败！";;
                warning_relogin_docker_group) default_message="请注销并重新登录以使 docker 用户组更改生效，之后您可以无需 sudo 运行 docker 命令。";;
                esac
            ;;
        *)
            case $message_id in
                docker_installing) default_message="Installing Docker...";;
                docker_install_success) default_message="Docker installation complete.";;
                docker_install_fail) default_message="Docker installation failed!";;
                docker_start_daemon) default_message="Starting Docker daemon...";;
                docker_start_success) default_message="Docker daemon started successfully.";;
                docker_start_fail) default_message="Failed to start Docker daemon!";;
                docker_enable_daemon) default_message="Enabling Docker daemon to start on boot...";;
                docker_enable_success) default_message="Docker daemon enabled to start on boot.";;
                docker_enable_fail) default_message="Failed to enable Docker daemon to start on boot!";;
                docker_add_user_group) default_message="Adding current user to docker group...";;
                docker_add_user_success) default_message="Current user added to docker group. Please log out and log back in for changes to take effect.";;
                docker_add_user_fail) default_message="Failed to add current user to docker group!";;
                warning_relogin_docker_group) default_message="Please log out and log back in for docker group changes to take effect. Then you can run docker commands without sudo.";;
                *) default_message="Unknown message ID: $message_id";;
            esac
            ;;
    esac
    printf "%b" "$default_message\n"
}

# --- 安装 Docker ---
get_localized_message docker_installing

apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg -y

# 添加 Docker GPG 密钥
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
if [ $? -ne 0 ]; then
    get_localized_message docker_install_fail
    return 1
fi

# 设置 Docker 仓库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
if [ $? -ne 0 ]; then
    get_localized_message docker_install_fail
    return 1
fi
get_localized_message docker_install_success

# --- 启动 Docker 服务并设置开机自启 ---
get_localized_message docker_start_daemon
systemctl start docker
if [ $? -ne 0 ]; then
    get_localized_message docker_start_fail
    return 1
fi
get_localized_message docker_start_success

get_localized_message docker_enable_daemon
systemctl enable docker
if [ $? -ne 0 ]; then
    get_localized_message docker_enable_fail
    return 1
fi
get_localized_message docker_enable_success

# --- 将当前用户添加到 docker 用户组 ---
get_localized_message docker_add_user_group
usermod -aG docker "$USER"
if [ $? -ne 0 ]; then
    get_localized_message docker_add_user_fail
    return 1
fi
get_localized_message docker_add_user_success
get_localized_message warning_relogin_docker_group

exit 0
