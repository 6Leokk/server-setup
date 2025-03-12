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
                update_system_start) default_message="正在更新系统软件包...";;
                update_system_success) default_message="系统软件包更新完成。";;
                update_system_fail) default_message="系统软件包更新失败！";;
                esac
            ;;
        *)
            case $message_id in
                update_system_start) default_message="Updating system packages...";;
                update_system_success) default_message="System packages update complete.";;
                update_system_fail) default_message="System packages update failed!";;
                *) default_message="Unknown message ID: $message_id";;
            esac
            ;;
    esac
    printf "%b" "$default_message\n"
}

# --- 更新系统 ---
get_localized_message update_system_start
apt-get update && apt-get dist-upgrade -y
if [ $? -ne 0 ]; then
    get_localized_message update_system_fail
    return 1
fi

get_localized_message update_system_success

exit 0
