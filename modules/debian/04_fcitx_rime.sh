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
                fcitx_rime_installing) default_message="正在安装 Fcitx5 和 Rime 输入法...";;
                fcitx_rime_install_success) default_message="Fcitx5 和 Rime 输入法安装完成。";;
                fcitx_rime_install_fail) default_message="Fcitx5 和 Rime 输入法安装失败！";;
                fcitx_rime_configuring) default_message="正在配置 Fcitx5 和 Rime...";;
                fcitx_rime_config_success) default_message="Fcitx5 和 Rime 配置完成。\n请注销并重新登录以应用输入法设置。";;
                fcitx_rime_config_fail) default_message="Fcitx5 和 Rime 配置失败！";;
                warning_relogin_required) default_message="请注销并重新登录以应用输入法设置。";;
                esac
            ;;
        *)
            case $message_id in
                fcitx_rime_installing) default_message="Installing Fcitx5 and Rime input method...";;
                fcitx_rime_install_success) default_message="Fcitx5 and Rime input method installation complete.";;
                fcitx_rime_install_fail) default_message="Fcitx5 and Rime input method installation failed!";;
                fcitx_rime_configuring) default_message="Configuring Fcitx5 and Rime...";;
                fcitx_rime_config_success) default_message="Fcitx5 and Rime configuration complete.\nPlease log out and log back in to apply input method settings.";;
                fcitx_rime_config_fail) default_message="Fcitx5 and Rime configuration failed!";;
                warning_relogin_required) default_message="Please log out and log back in to apply input method settings.";;
                *) default_message="Unknown message ID: $message_id";;
            esac
            ;;
    esac
    printf "%b" "$default_message\n"
}

# --- 安装 Fcitx5 和 Rime ---
get_localized_message fcitx_rime_installing
apt-get install fcitx5 fcitx5-rime -y
if [ $? -ne 0 ]; then
    get_localized_message fcitx_rime_install_fail
    return 1
fi
get_localized_message fcitx_rime_install_success

# --- 配置 Fcitx5 和 Rime (简单配置，可能需要更详细的配置) ---
get_localized_message fcitx_rime_configuring

# 设置 Fcitx5 为默认输入法
im-config -n fcitx5
if [ $? -ne 0 ]; then
    get_localized_message fcitx_rime_config_fail
    return 1
fi

# 可以添加更详细的 Rime 配置，例如修改 default.custom.yaml 等
# 这里为了简化，只进行基本安装和设置

get_localized_message fcitx_rime_config_success
get_localized_message warning_relogin_required

exit 0
