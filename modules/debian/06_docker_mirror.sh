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
                docker_mirror_configuring) default_message="正在配置 Docker 镜像加速...";;
                docker_mirror_config_success) default_message="Docker 镜像加速配置完成。\n请重启 Docker 服务以应用更改。";;
                docker_mirror_config_fail) default_message="Docker 镜像加速配置失败！";;
                docker_mirror_restart_daemon) default_message="正在重启 Docker 服务以应用镜像加速配置...";;
                docker_mirror_restart_success) default_message="Docker 服务重启成功。";;
                docker_mirror_restart_fail) default_message="Docker 服务重启失败！请手动重启 Docker 服务。";;
                docker_mirror_prompt) default_message="请选择 Docker 镜像加速服务：\n  1 - 中科大 (USTC, 默认)\n  2 - 清华大学 (TUNA)\n  3 - 南京大学 (NJU)\n  4 - 阿里云 (Aliyun)\n  5 - Docker 官方加速 (Docker Hub Official)\n  6 - 不使用镜像加速\n请选择 (1-6, 默认: 1, 30秒超时): ";;
                docker_mirror_invalid_choice) default_message="无效的选择，请重新选择 (1-6)。";;
                docker_mirror_ustc) default_message="中科大镜像源";;
                docker_mirror_tsinghua) default_message="清华大学镜像源";;
                docker_mirror_nju) default_message="南京大学镜像源";;
                docker_mirror_aliyun) default_message="阿里云镜像源";;
                docker_mirror_dockerhub) default_message="Docker 官方加速";;
                docker_mirror_no_mirror) default_message="不使用镜像加速";;
                warning_restart_docker_daemon) default_message="请重启 Docker 服务以应用镜像加速配置。";;
                esac
            ;;
        *)
            case $message_id in
                docker_mirror_configuring) default_message="Configuring Docker mirror acceleration...";;
                docker_mirror_config_success) default_message="Docker mirror acceleration configuration complete.\nPlease restart Docker service to apply changes.";;
                docker_mirror_config_fail) default_message="Docker mirror acceleration configuration failed!";;
                docker_mirror_restart_daemon) default_message="Restarting Docker service to apply mirror acceleration configuration...";;
                docker_mirror_restart_success) default_message="Docker service restarted successfully.";;
                docker_mirror_restart_fail) default_message="Docker service restart failed! Please restart Docker service manually.";;
                docker_mirror_prompt) default_message="Please choose Docker mirror acceleration service:\n  1 - USTC (University of Science and Technology of China, default)\n  2 - Tsinghua University (TUNA)\n  3 - Nanjing University (NJU)\n  4 - Aliyun (Alibaba Cloud)\n  5 - Docker Hub Official\n  6 - Do not use mirror acceleration\nPlease choose (1-6, default: 1, 30s timeout): ";;
                docker_mirror_invalid_choice) default_message="Invalid choice, please choose again (1-6).";;
                docker_mirror_ustc) default_message="USTC Mirror";;
                docker_mirror_tsinghua) default_message="Tsinghua University Mirror";;
                docker_mirror_nju) default_message="Nanjing University Mirror";;
                docker_mirror_aliyun) default_message="Aliyun Mirror";;
                docker_mirror_dockerhub) default_message="Docker Hub Official Mirror";;
                docker_mirror_no_mirror) default_message="No mirror acceleration";;
                warning_restart_docker_daemon) default_message="Please restart Docker service to apply mirror acceleration configuration.";;
                *) default_message="Unknown message ID: $message_id";;
            esac
            ;;
    esac
    printf "%b" "$default_message\n"
}

# --- 选择 Docker 镜像加速服务 ---
while true; do
    timeout 30 read -r -p "$(get_localized_message docker_mirror_prompt)" mirror_choice
    if [[ -z "$mirror_choice" ]]; then
        mirror_choice="1" # 默认中科大
    fi
    case "$mirror_choice" in
        1) mirror_url="https://mirrors.ustc.edu.cn/docker-registry/"; mirror_name="$(get_localized_message docker_mirror_ustc)"; break ;;
        2) mirror_url="https://mirrors.tuna.tsinghua.edu.cn/docker-registry/"; mirror_name="$(get_localized_message docker_mirror_tsinghua)"; break ;;
        3) mirror_url="https://mirror.nju.edu.cn/docker-registry/"; mirror_name="$(get_localized_message docker_mirror_nju)"; break ;;
        4) mirror_url="https://xxxxxxxxx.mirror.aliyuncs.com"; mirror_name="$(get_localized_message docker_mirror_aliyun)"; break ;; # 需要替换为实际的阿里云加速地址
        5) mirror_url="https://registry.docker-cn.com"; mirror_name="$(get_localized_message docker_mirror_dockerhub)"; break ;; # Docker 官方中国区加速
        6) mirror_url=""; mirror_name="$(get_localized_message docker_mirror_no_mirror)"; break ;; # 不使用镜像加速
        *) get_localized_message docker_mirror_invalid_choice ;;
    esac
done

get_localized_message docker_mirror_configuring

if [[ -n "$mirror_url" ]]; then
    # 配置 Docker Daemon
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["$mirror_url"]
}
EOF
else
    # 如果选择不使用镜像加速，则删除 daemon.json 文件 (如果存在)
    rm -f /etc/docker/daemon.json
fi


if [ $? -ne 0 ]; then
    get_localized_message docker_mirror_config_fail
    return 1
fi

get_localized_message docker_mirror_config_success
echo "- $(get_localized_message docker_mirror_config_success)"
echo "- $(get_localized_message docker_mirror_no_mirror): $mirror_name"

# --- 重启 Docker 服务 ---
get_localized_message docker_mirror_restart_daemon
systemctl restart docker
if [ $? -ne 0 ]; then
    get_localized_message docker_mirror_restart_fail
    get_localized_message warning_restart_docker_daemon
    return 1 # 重启失败，但配置可能已经写入，不完全算失败
fi
get_localized_message docker_mirror_restart_success

exit 0
