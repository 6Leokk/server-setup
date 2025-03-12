#!/bin/bash

# --- 全局变量 ---
GITHUB_REPO="https://github.com/6Leokk/server-setup/edit/main"
MODULES_DIR="$GITHUB_REPO/modules/debian"

# 模块配置（编号:文件名:消息ID）
modules=(
    "01:01_system_lang.sh:lang_setup"
    "02:02_software_sources.sh:sources_setup"
    "03:03_system_update.sh:update_system"
    "04:04_fcitx_rime.sh:fcitx_rime_setup"
    "05:05_docker_setup.sh:docker_setup"
    "06:06_docker_mirror.sh:docker_mirror_setup"
)

# 脚本语言变量，模块可以通过此变量判断脚本使用的语言
export SCRIPT_LANG=""

# --- 函数定义 ---

# 国际化支持 (i18n)
get_localized_message() {
    local lang=${SCRIPT_LANG:-${LANG%.*}}  # 优先使用脚本语言，否则使用系统语言
    local message_id="$1"
    local default_message=""

    case $lang in
        zh_CN*)
            case $message_id in
                welcome) default_message="欢迎使用服务器配置脚本！";;
                select_lang) default_message="1 - 选择脚本使用的语言为中文, 2 - 选择英文 (默认: 1, 30秒超时): ";;
                lang_setup) default_message="正在设置系统语言...";;
                sources_setup) default_message="正在配置软件源...";;
                update_system) default_message="正在更新系统...";;
                fcitx_rime_setup) default_message="正在安装和配置 Fcitx5 + Rime 输入法...";;
                docker_setup) default_message="正在安装 Docker...";;
                docker_mirror_setup) default_message="正在配置 Docker 镜像加速...";;
                reboot_prompt) default_message="配置完成。是否立即重启以应用更改？ (y/n, 默认: n, 30秒超时): ";;
                goodbye) default_message="感谢使用，再见！";;
                error_not_root) default_message="错误：此脚本必须以 root 用户身份运行。";;
                invalid_lang_choice) default_message="无效的语言选择。";;
                module_failed) default_message="错误：无法加载模块 %2";;
                module_list) default_message="可用模块列表：";;
                module_prompt) default_message="请输入要执行的模块编号（多个用空格分隔，all 或回车为全部，-1 排除模块1, 默认: all, 30秒超时）:";;
                invalid_module) default_message="错误：无效的模块编号：";;
                unsupported_lang) default_message="警告：不支持的语言 $lang，已切换为英文";;
                module_reboot_forbidden) default_message="错误：模块禁止直接重启系统。重启操作应由主安装脚本控制。";;
                module_start) default_message="--- 模块 %s 开始 ---";;
                module_end) default_message="--- 模块 %s 结束 ---";;
                downloading_module) default_message="正在下载模块 %s...";;
                module_executed) default_message="模块 %s 执行完成。";;
                module_skipped) default_message="模块 %s 已跳过。";;
                no_modules_selected) default_message="没有选择任何模块。";;
                confirm_reboot) default_message="确认重启系统吗？ (y/n, 默认: n, 30秒超时)";;
                rebooting) default_message="正在重启系统...";;
                aborting_reboot) default_message="已取消重启。";;
                module_error_prefix) default_message="模块错误：";;
                module_output_prefix) default_message="模块输出：";;
                script_error_prefix) default_message="脚本错误：";;
                script_warning_prefix) default_message="脚本警告：";;
                script_info_prefix) default_message="脚本信息：";;
                module_status_prefix) default_message="模块状态：";;
                press_enter_to_continue) default_message="按 Enter 键继续...";;
                module_dependency_error) default_message="模块 %s 依赖 %s，但 %s 执行失败，请检查。";;
                esac
            ;;
        *)
            # 英文处理 (默认)
            case $message_id in
                welcome) default_message="Welcome to the server setup script!";;
                select_lang) default_message="1 - Select Chinese, 2 - Select English (default: 1, 30s timeout): ";;
                lang_setup) default_message="Setting up system language...";;
                sources_setup) default_message="Configuring software sources...";;
                update_system) default_message="Updating the system...";;
                fcitx_rime_setup) default_message="Installing and configuring Fcitx5 + Rime input method...";;
                docker_setup) default_message="Installing Docker...";;
                docker_mirror_setup) default_message="Configuring Docker mirror acceleration...";;
                reboot_prompt) default_message="Setup complete. Reboot now to apply changes? (y/n, default: n, 30s timeout): ";;
                goodbye) default_message="Thank you, goodbye!";;
                error_not_root) default_message="ERROR: This script must be run as root.";;
                invalid_lang_choice) default_message="Invalid language choice.";;
                module_failed) default_message="ERROR: Failed to load module %2";;
                module_list) default_message="Available modules:";;
                module_prompt) default_message="Enter module numbers to execute (space separated, 'all' or enter for all, '-1' to exclude module 1, default: all, 30s timeout):";;
                invalid_module) default_message="ERROR: Invalid module numbers:";;
                unsupported_lang) default_message="Warning: Unsupported language $lang, defaulting to English";;
                module_reboot_forbidden) default_message="ERROR: Modules are forbidden to reboot the system directly. Reboot should be controlled by the main installation script.";;
                module_start) default_message="--- Module %s Start ---";;
                module_end) default_message="--- Module %s End ---";;
                downloading_module) default_message="Downloading module %s...";;
                module_executed) default_message="Module %s executed successfully.";;
                module_skipped) default_message="Module %s skipped.";;
                no_modules_selected) default_message="No modules selected.";;
                confirm_reboot) default_message="Confirm system reboot? (y/n, default: n, 30s timeout)";;
                rebooting) default_message="Rebooting system...";;
                aborting_reboot) default_message="Reboot aborted.";;
                module_error_prefix) default_message="Module Error: ";;
                module_output_prefix) default_message="Module Output: ";;
                script_error_prefix) default_message="Script Error: ";;
                script_warning_prefix) default_message="Script Warning: ";;
                script_info_prefix) default_message="Script Info: ";;
                module_status_prefix) default_message="Module Status: ";;
                press_enter_to_continue) default_message="Press Enter to continue...";;
                module_dependency_error) default_message="Module %s depends on %s, but %s failed, please check.";;
                *)
                    # 默认英文消息，并输出警告到 stderr
                    if [[ "$lang" != "en_US" ]]; then
                        printf "%b" "$(get_localized_message unsupported_lang)\n" >&2
                    fi
                    default_message="Unknown message ID: $message_id" # 默认英文错误消息
                ;;
            esac
            ;;
    esac

    printf "%b" "$default_message" "$@" # 使用 printf 支持格式化字符串
}


# --- 改进的函数 ---

check_root() {
    if [ "$EUID" -ne 0 ]; then
        printf "%b" "$(get_localized_message error_not_root)\n" >&2
        exit 1
    fi
}

load_module() {
    local filename="$1"
    local module_url="$MODULES_DIR/$filename"
    local module_content
    local retries=3
    local attempt=0
    local success=0

    printf "%b" "$(get_localized_message downloading_module "$filename")\n"

    # 带重试机制的下载
    while [[ $attempt -lt $retries ]]; do
        module_content=$(curl -sSL "$module_url" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$module_content" ]; then
            success=1
            break
        fi
        ((attempt++))
        sleep 1
    done

    if [ $success -eq 0 ]; then
        printf "%b" "$(get_localized_message module_failed "$filename")\n" >&2
        return 1 # 返回非零状态码表示失败
    fi

    # 使用临时文件进行错误处理
    local temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' EXIT
    echo "$module_content" > "$temp_file"

    printf "%b" "$(get_localized_message module_start "$filename")\n"

    # 严格错误检查，并传递脚本语言变量
    (
        set -e # 任何命令失败都立即退出
        set -o pipefail # 管道错误也返回错误状态
        export SCRIPT_LANG # 传递脚本语言给模块
        source "$temp_file"
    )
    local result=$?

    printf "%b" "$(get_localized_message module_end "$filename")\n"

    if [ $result -ne 0 ]; then
        printf "%b" "$(get_localized_message module_failed "$filename")\n" >&2
        rm -f "$temp_file" # 确保清理临时文件
        return $result # 返回模块的错误状态码
    fi

    rm -f "$temp_file"
    printf "%b" "$(get_localized_message module_executed "$filename")\n"
    return 0 # 返回成功状态码
}

check_module_reboot() {
    echo "$(get_localized_message module_reboot_forbidden)" >&2
    return 1 # 模块尝试重启，返回错误
}

# --- 主程序逻辑 ---

check_root

# 语言选择增强
while true; do
    timeout 30 read -r -p "$(get_localized_message select_lang)" lang_choice
    if [[ -z "$lang_choice" ]]; then
        lang_choice="1" # 默认中文
    fi
    case $lang_choice in
        1) SCRIPT_LANG="zh_CN"; break ;;
        2) SCRIPT_LANG="en_US"; break ;;
        *) printf "%b" "$(get_localized_message invalid_lang_choice)\n" ;;
    esac
done

printf "%b" "$(get_localized_message welcome)\n"

# 显示模块列表
printf "%b" "\n$(get_localized_message module_list)\n"
for module in "${modules[@]}"; do
    IFS=':' read -r num _ message <<< "$module"
    printf "%b" "  [%s] %s\n" "$num" "$(get_localized_message "$message")"
done

# 读取用户输入
printf "%b" "\n"
while true; do
    timeout 30 read -r -p "$(get_localized_message module_prompt) " input
    if [[ -z "$input" ]]; then
        input="all" # 默认全部模块
        break
    fi
    input=${input:-"all"}

    # 输入处理增强
    include=()
    exclude=()
    invalid=()
    processed=()

    # 分割输入为数组
    IFS=' ' read -ra items <<< "$input"

    # 处理特殊值
    if [[ " ${items[*]} " =~ " all " ]] || [[ " ${items[*]} " == "all" ]]; then
        for module in "${modules[@]}"; do
            IFS=':' read -r num _ _ <<< "$module"
            include+=("$num")
        done
        break
    elif [[ " ${items[*]} " =~ " none " ]] || [[ " ${items[*]} " == "none" ]]; then
        printf "%b" "$(get_localized_message no_modules_selected)\n"
        exit 0
    else
        valid_input=1
        for item in "${items[@]}"; do
            # 去重检查
            if [[ " ${processed[*]} " =~ " $item " ]]; then
                continue
            fi
            processed+=("$item")

            if [[ $item == -* ]]; then
                num=${item#-}
                found=0
                for module in "${modules[@]}"; do
                    IFS=':' read -r m_num _ _ <<< "$module"
                    [[ $m_num == "$num" ]] && found=1 && break
                done
                if [[ $found -eq 1 ]]; then
                    exclude+=("$num")
                else
                    invalid+=("$num")
                    valid_input=0
                fi
            else
                found=0
                for module in "${modules[@]}"; do
                    IFS=':' read -r m_num _ _ <<< "$module"
                    [[ $m_num == "$item" ]] && found=1 && break
                done
                if [[ $found -eq 1 ]]; then
                    include+=("$item")
                else
                    invalid+=("$item")
                    valid_input=0
                fi
            fi
        done
        if [[ $valid_input -eq 1 ]]; then
            break # 输入有效，退出循环
        else
            # 检查无效输入
            if [[ ${#invalid[@]} -gt 0 ]]; then
                printf "%b" "$(get_localized_message invalid_module) %s\n" "${invalid[*]}" >&2
                # 不退出，允许用户重新输入
            fi
        fi
    fi
done


# 生成最终模块列表
selected_modules=()

# 去重处理
include=($(printf "%s\n" "${include[@]}" | sort -u))
exclude=($(printf "%s\n" "${exclude[@]}" | sort -u))

# 如果没有指定包含，且没有输入 "none"，则默认包含所有
if [[ ${#include[@]} -eq 0 ]] && ! [[ " ${items[*]} " =~ " none " ]] && ! [[ " ${items[*]} " == "none" ]]; then
    for module in "${modules[@]}"; do
        IFS=':' read -r num _ _ <<< "$module"
        include+=("$num")
    done
fi

# 过滤模块
for module in "${modules[@]}"; do
    IFS=':' read -r num filename message <<< "$module"

    in_include=0
    for i in "${include[@]}"; do
        [[ $i == "$num" ]] && in_include=1 && break
    done

    in_exclude=0
    for e in "${exclude[@]}"; do
        [[ $e == "$num" ]] && in_exclude=1 && break
    done

    if [[ $in_include -eq 1 && $in_exclude -eq 0 ]]; then
        selected_modules+=("$module")
    fi
done

# 如果没有选择任何模块，直接退出
if [[ ${#selected_modules[@]} -eq 0 ]]; then
    printf "%b" "$(get_localized_message no_modules_selected)\n"
    exit 0
fi

# 按模块编号排序
IFS=$'\n' sorted_modules=($(sort -t: -k1n <<< "${selected_modules[*]}"))
unset IFS

# 执行模块增强
module_status=() # 记录模块执行状态，用于依赖检查
for module in "${sorted_modules[@]}"; do
    IFS=':' read -r num filename message <<< "$module"
    printf "%b" "\n=== $(get_localized_message "$message") ===\n"

    if load_module "$filename"; then
        module_status["$num"]="success"
    else
        module_status["$num"]="failed"
        printf "%b" "$(get_localized_message module_status_prefix) $(get_localized_message module_failed "$filename")\n"
        # 这里可以根据需要决定是否继续执行后续模块，或者直接退出
        # 例如，如果某个模块是关键依赖，可以考虑退出
        # 这里为了演示，先继续执行，但你可以根据实际情况修改
        # exit $?  # 如果希望模块失败立即退出，可以取消注释这行
    fi
done

# 重启提示
printf "%b" "\n"
while true; do
    timeout 30 read -r -p "$(get_localized_message reboot_prompt) " response
    if [[ -z "$response" ]]; then
        response="n" # 默认不重启
    fi
    response=${response,,}
    if [[ $response =~ ^(yes|y)$ ]]; then
        while true; do
            timeout 30 read -r -p "$(get_localized_message confirm_reboot) " confirm_reboot_response
            if [[ -z "$confirm_reboot_response" ]]; then
                confirm_reboot_response="n" # 默认不重启
            fi
            confirm_reboot_response=${confirm_reboot_response,,}
            if [[ $confirm_reboot_response =~ ^(yes|y)$ ]]; then
                printf "%b" "$(get_localized_message rebooting)\n"
                reboot
                exit 0 # reboot 后脚本结束
            elif [[ $confirm_reboot_response =~ ^(no|n)$ ]]; then
                printf "%b" "$(get_localized_message aborting_reboot)\n"
                break 2 # 跳出两层循环
            else
                printf "%b" "$(get_localized_message invalid_lang_choice)\n" # 复用无效语言提示
            fi
        done
    elif [[ $response =~ ^(no|n)$ ]]; then
        printf "%b" "$(get_localized_message aborting_reboot)\n"
        break # 跳出外层循环
    else
        printf "%b" "$(get_localized_message invalid_lang_choice)\n" # 复用无效语言提示
    fi
done


printf "%b" "\n$(get_localized_message goodbye)\n"
exit 0
