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
                sources_detect_os) default_message="正在检测您的 Debian 系统版本...";;
                sources_os_detected) default_message="检测到您的 Debian 系统版本为： %s";;
                sources_get_codename_fail) default_message="未能获取 Debian 系统代号。";;
                sources_foreign_user_skip) default_message="检测到您可能不是中国大陆用户，跳过更换软件源。如果您需要更换软件源，请手动修改 /etc/apt/sources.list 文件。";;
                sources_china_user_prompt) default_message="检测到您可能是中国大陆用户，为了更快的软件更新速度，您可以选择更换为国内镜像源：\n  1 - 中科大 (USTC, 默认)\n  2 - 清华大学 (TUNA)\n  3 - 南京大学 (NJU)\n  4 - 阿里云 (Aliyun)\n  5 - 保持默认源\n请选择 (1-5, 默认: 1, 30秒超时): ";;
                sources_invalid_choice) default_message="无效的选择，请重新选择 (1-5)。";;
                sources_backup_original) default_message="正在备份原始软件源列表...";;
                sources_backup_success) default_message="原始软件源列表备份成功，备份文件为： %s";;
                sources_backup_fail) default_message="原始软件源列表备份失败！";;
                sources_replace_ustc) default_message="正在更换为中科大 (USTC) 镜像源...";;
                sources_replace_tsinghua) default_message="正在更换为清华大学 (TUNA) 镜像源...";;
                sources_replace_nju) default_message="正在更换为南京大学 (NJU) 镜像源...";;
                sources_replace_aliyun) default_message="正在更换为阿里云 (Aliyun) 镜像源...";;
                sources_replace_default) default_message="保持默认软件源。";;
                sources_replace_success) default_message="软件源更换成功！";;
                sources_replace_fail) default_message="软件源更换失败！";;
                error_apt_get_update) default_message="错误：apt-get update 命令执行失败。";;
                esac
            ;;
        *)
            case $message_id in
                sources_detect_os) default_message="Detecting your Debian system version...";;
                sources_os_detected) default_message="Detected your Debian system version: %s";;
                sources_get_codename_fail) default_message="Failed to get Debian system codename.";;
                sources_foreign_user_skip) default_message="Detected that you might not be a user in mainland China. Skipping software source replacement. If you need to change software sources, please manually modify /etc/apt/sources.list file.";;
                sources_china_user_prompt) default_message="Detected that you might be a user in mainland China. For faster software update speed, you can choose to replace with a domestic mirror source:\n  1 - USTC (University of Science and Technology of China, default)\n  2 - Tsinghua University (TUNA)\n  3 - Nanjing University (NJU)\n  4 - Aliyun (Alibaba Cloud)\n  5 - Keep default sources\nPlease choose (1-5, default: 1, 30s timeout): ";;
                sources_invalid_choice) default_message="Invalid choice, please choose again (1-5).";;
                sources_backup_original) default_message="Backing up original software source list...";;
                sources_backup_success) default_message="Original software source list backup successful, backup file is: %s";;
                sources_backup_fail) default_message="Failed to backup original software source list!";;
                sources_replace_ustc) default_message="Replacing with USTC mirror source...";;
                sources_replace_tsinghua) default_message="Replacing with Tsinghua University (TUNA) mirror source...";;
                sources_replace_nju) default_message="Replacing with Nanjing University (NJU) mirror source...";;
                sources_replace_aliyun) default_message="Replacing with Aliyun mirror source...";;
                sources_replace_default) default_message="Keeping default software sources.";;
                sources_replace_success) default_message="Software source replacement successful!";;
                sources_replace_fail) default_message="Software source replacement failed!";;
                error_apt_get_update) default_message="ERROR: apt-get update command failed.";;
                *) default_message="Unknown message ID: $message_id";;
            esac
            ;;
    esac
    printf "%b" "$default_message\n"
}

# --- 获取 Debian 系统代号 ---
get_localized_message sources_detect_os
debian_codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
if [[ -z "$debian_codename" ]]; then
    get_localized_message sources_get_codename_fail
    return 1
fi
get_localized_message sources_os_detected "$debian_codename"

# --- 判断是否为中国大陆用户 (简单判断，可能不准确) ---
# 这里可以根据 IP 地址、地理位置信息等更准确地判断
is_china_user=false
if ip route | grep -q "cnnic"; then # 简单的路由判断
    is_china_user=true
fi

if ! "$is_china_user"; then
    get_localized_message sources_foreign_user_skip
    return 0
fi

# --- 中国大陆用户，提示选择镜像源 ---
while true; do
    timeout 30 read -r -p "$(get_localized_message sources_china_user_prompt)" source_choice
    if [[ -z "$source_choice" ]]; then
        source_choice="1" # 默认中科大
    fi
    case "$source_choice" in
        1) mirror_site="ustc"; break ;;
        2) mirror_site="tsinghua"; break ;;
        3) mirror_site="nju"; break ;;
        4) mirror_site="aliyun"; break ;;
        5) mirror_site="default"; break ;;
        *) get_localized_message sources_invalid_choice ;;
    esac
done

if [[ "$mirror_site" == "default" ]]; then
    get_localized_message sources_replace_default
    return 0
fi

# --- 备份原始 sources.list ---
get_localized_message sources_backup_original
backup_file="/etc/apt/sources.list.backup.$(date +%Y%m%d%H%M%S)"
cp /etc/apt/sources.list "$backup_file"
if [ $? -ne 0 ]; then
    get_localized_message sources_backup_fail
    return 1
fi
get_localized_message sources_backup_success "$backup_file"

# --- 根据选择更换软件源 ---
case "$mirror_site" in
    ustc)
        get_localized_message sources_replace_ustc
        mirror_url="mirrors.ustc.edu.cn"
        ;;
    tsinghua)
        get_localized_message sources_replace_tsinghua
        mirror_url="mirrors.tuna.tsinghua.edu.cn"
        ;;
    nju)
        get_localized_message sources_replace_nju
        mirror_url="mirrors.nju.edu.cn"
        ;;
    aliyun)
        get_localized_message sources_replace_aliyun
        mirror_url="mirrors.aliyun.com"
        ;;
esac

if [[ "$mirror_site" != "default" ]]; then
    cat > /etc/apt/sources.list <<EOL
deb http://${mirror_url}/debian/ ${debian_codename} main contrib non-free
deb-src http://${mirror_url}/debian/ ${debian_codename} main contrib non-free

deb http://${mirror_url}/debian/ ${debian_codename}-updates main contrib non-free
deb-src http://${mirror_url}/debian/ ${debian_codename}-updates main contrib non-free

deb http://${mirror_url}/debian-security/ ${debian_codename}-security main contrib non-free
deb-src http://${mirror_url}/debian-security/ ${debian_codename}-security main contrib non-free

deb http://${mirror_url}/debian/ ${debian_codename}-backports main contrib non-free
deb-src http://${mirror_url}/debian/ ${debian_codename}-backports main contrib non-free
EOL
fi


if [ $? -ne 0 ]; then
    get_localized_message sources_replace_fail
    return 1
fi

get_localized_message sources_replace_success

# --- 更新 apt 缓存 ---
apt-get update
if [ $? -ne 0 ]; then
    get_localized_message error_apt_get_update
    get_localized_message sources_replace_fail # 更新失败也提示源更换失败，因为源配置可能不正确
    return 1
fi

exit 0
