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
                lang_setting_up) default_message="正在配置系统语言为中文...";;
                lang_set_success) default_message="系统语言已成功设置为中文。";;
                lang_set_fail) default_message="设置系统语言为中文失败。";;
                lang_already_set) default_message="系统语言已设置为中文，跳过。";;
                lang_setting_english) default_message="正在配置系统语言为英文...";;
                lang_set_english_success) default_message="系统语言已成功设置为英文。";;
                lang_set_english_fail) default_message="设置系统语言为英文失败。";;
                lang_english_already_set) default_message="系统语言已设置为英文，跳过。";;
                error_locale_gen) default_message="错误：locale-gen 命令执行失败。";;
                error_dpkg_reconfigure) default_message="错误：dpkg-reconfigure locales 命令执行失败。";;
                warning_locale_not_installed) default_message="警告：locales 包未安装，请确保已安装 locales 包。";;
                esac
            ;;
        *)
            case $message_id in
                lang_setting_up) default_message="Setting up system language to Chinese...";;
                lang_set_success) default_message="System language has been successfully set to Chinese.";;
                lang_set_fail) default_message="Failed to set system language to Chinese.";;
                lang_already_set) default_message="System language is already set to Chinese, skipping.";;
                lang_setting_english) default_message="Setting up system language to English...";;
                lang_set_english_success) default_message="System language has been successfully set to English.";;
                lang_set_english_fail) default_message="Failed to set system language to English.";;
                lang_english_already_set) default_message="System language is already set to English, skipping.";;
                error_locale_gen) default_message="ERROR: locale-gen command failed.";;
                error_dpkg_reconfigure) default_message="ERROR: dpkg-reconfigure locales command failed.";;
                warning_locale_not_installed) default_message="Warning: locales package is not installed. Please ensure locales package is installed.";;
                *) default_message="Unknown message ID: $message_id";;
            esac
            ;;
    esac
    printf "%b" "$default_message\n"
}

# --- 检查 locales 包是否安装 ---
if ! dpkg -s locales >/dev/null 2>&1; then
    get_localized_message warning_locale_not_installed
    return 1 # 如果 locales 未安装，模块执行失败
fi

# --- 根据脚本语言设置系统语言 ---
if [[ "$script_lang" == "zh_CN" ]]; then
    # 检查当前语言是否已经是中文
    current_lang=$(locale | grep LANG= | awk -F= '{print $2}' | head -n 1)
    if [[ "$current_lang" == "zh_CN.UTF-8" ]]; then # 或者其他中文 locale，根据实际情况调整
        get_localized_message lang_already_set
        return 0
    fi

    get_localized_message lang_setting_up

    # 生成中文 locale，并设置为默认
    locale-gen zh_CN.UTF-8
    if [ $? -ne 0 ]; then
        get_localized_message error_locale_gen
        return 1
    fi

    dpkg-reconfigure locales -f noninteractive
    if [ $? -ne 0 ]; then
        get_localized_message error_dpkg_reconfigure
        get_localized_message lang_set_fail
        return 1
    fi

    update-locale LANG=zh_CN.UTF-8
    if [ $? -ne 0 ]; then
        get_localized_message error_dpkg_reconfigure
        get_localized_message lang_set_fail
        return 1
    fi


    get_localized_message lang_set_success

elif [[ "$script_lang" == "en_US" ]]; then
    # 检查当前语言是否已经是英文
    current_lang=$(locale | grep LANG= | awk -F= '{print $2}' | head -n 1)
    if [[ "$current_lang" == "en_US.UTF-8" ]]; # 或者其他英文 locale，根据实际情况调整
        get_localized_message lang_english_already_set
        return 0
    fi

    get_localized_message lang_setting_english

    # 生成英文 locale，并设置为默认
    locale-gen en_US.UTF-8
    if [ $? -ne 0 ]; then
        get_localized_message error_locale_gen
        return 1
    fi

    dpkg-reconfigure locales -f noninteractive
    if [ $? -ne 0 ]; then
        get_localized_message error_dpkg_reconfigure
        get_localized_message lang_set_english_fail
        return 1
    fi

    update-locale LANG=en_US.UTF-8
    if [ $? -ne 0 ]; then
        get_localized_message error_dpkg_reconfigure
        get_localized_message lang_set_english_fail
        return 1
    fi

    get_localized_message lang_set_english_success
else
    # 默认情况，可以设置为英文，或者保持系统默认
    get_localized_message lang_setting_english

    locale-gen en_US.UTF-8
    if [ $? -ne 0 ]; then
        get_localized_message error_locale_gen
        return 1
    fi

    dpkg-reconfigure locales -f noninteractive
    if [ $? -ne 0 ]; then
        get_localized_message error_dpkg_reconfigure
        get_localized_message lang_set_english_fail
        return 1
    fi

    update-locale LANG=en_US.UTF-8
    if [ $? -ne 0 ]; then
        get_localized_message error_dpkg_reconfigure
        get_localized_message lang_set_english_fail
        return 1
    fi
    get_localized_message lang_set_english_success
fi

exit 0
