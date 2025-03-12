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

# --- 函数定义 ---

# 国际化支持 (i18n)
get_localized_message() {
    local lang=${SELECTED_LANG:-${LANG%.*}}  # 获取基础语言代码

    case $lang in
        zh_CN*)
            case $1 in
                welcome) echo "欢迎使用服务器配置脚本！";;
                select_lang) echo "1 - 选择脚本使用的语言为中文, 2 - Select English as the script language): ";;
                lang_setup) echo "正在设置系统语言...";;
                sources_setup) echo "正在配置软件源...";;
                update_system) echo "正在更新系统...";;
                fcitx_rime_setup) echo "正在安装和配置 Fcitx5 + Rime 输入法...";;
                docker_setup) echo "正在安装 Docker...";;
                docker_mirror_setup) echo "正在配置 Docker 镜像加速...";;
                reboot_prompt) echo "配置完成。是否立即重启以应用更改？ (y/n)";;
                goodbye) echo "感谢使用，再见！";;
                error_not_root) echo "错误：此脚本必须以 root 用户身份运行。";;
                invalid_lang_choice) echo "无效的语言选择。";;
                module_failed) echo "错误：无法加载模块 $2";;
                module_list) echo "可用模块列表：";;
                module_prompt) echo "请输入要执行的模块编号（多个用空格分隔，all 或回车为全部，-1 排除模块1）:";;
                invalid_module) echo "错误：无效的模块编号：";;
                unsupported_lang) echo "警告：不支持的语言 $lang，已切换为英文";;
            esac
            ;;
        *)  
            # 显示语言不支持警告
            if [[ "$lang" != "en_US" ]]; then
                case $1 in
                    unsupported_lang) echo "Warning: Unsupported language $lang, defaulting to English";;
                esac >&2
            fi
            # 英文处理
            case $1 in
                welcome) echo "Welcome to the server setup script!";;
                select_lang) echo "1 - Select Chinese as the script language, 2 - 选择脚本使用英文): ";;
                lang_setup) echo "Setting up system language...";;
                sources_setup) echo "Configuring software sources...";;
                update_system) echo "Updating the system...";;
                fcitx_rime_setup) echo "Installing and configuring Fcitx5 + Rime input method...";;
                docker_setup) echo "Installing Docker...";;
                docker_mirror_setup) echo "Configuring Docker mirror acceleration...";;
                reboot_prompt) echo "Setup complete. Reboot now to apply changes? (y/n)";;
                goodbye) echo "Thank you, goodbye!";;
                error_not_root) echo "ERROR: This script must be run as root.";;
                invalid_lang_choice) echo "Invalid language choice.";;
                module_failed) echo "ERROR: Failed to load module $2";;
                module_list) echo "Available modules:";;
                module_prompt) echo "Enter module numbers to execute (space separated, 'all' or enter for all, '-1' to exclude module 1):";;
                invalid_module) echo "ERROR: Invalid module numbers:";;
            esac
            ;;
    esac
}

# --- 改进的函数 ---

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "$(get_localized_message error_not_root)"
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
        echo "$(get_localized_message module_failed) $filename" >&2
        exit 1
    fi

    # 使用临时文件进行错误处理
    local temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' EXIT
    echo "$module_content" > "$temp_file"

    # 严格错误检查
    (
        set -e
        export SELECTED_LANG
        source "$temp_file"
    )
    local result=$?
    
    if [ $result -ne 0 ]; then
        echo "$(get_localized_message module_failed) $filename" >&2
        exit $result
    fi

    rm -f "$temp_file"
}

# --- 改进的主程序逻辑 ---

check_root

# 语言选择增强
while true; do
    # 显示语言不支持警告
    if [[ -n "$SELECTED_LANG" && "${SELECTED_LANG%.*}" != "zh_CN" ]]; then
        echo "$(get_localized_message unsupported_lang)" >&2
    fi

    read -r -p "$(get_localized_message select_lang)" lang_choice
    case $lang_choice in
        1) SELECTED_LANG="zh_CN"; break ;;
        2) SELECTED_LANG="en_US"; break ;;
        *) echo "$(get_localized_message invalid_lang_choice)" ;;
    esac
done

echo "$(get_localized_message welcome)"

# 显示模块列表
echo
echo "$(get_localized_message module_list)"
for module in "${modules[@]}"; do
    IFS=':' read -r num _ message <<< "$module"
    echo "  [$num] $(get_localized_message "$message")"
done

# 读取用户输入
echo
read -r -p "$(get_localized_message module_prompt) " input
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
else
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
            fi
        fi
    done
fi

# 检查无效输入
if [[ ${#invalid[@]} -gt 0 ]]; then
    echo "$(get_localized_message invalid_module) ${invalid[*]}" >&2
    exit 1
fi

# 生成最终模块列表
selected_modules=()

# 去重处理
include=($(printf "%s\n" "${include[@]}" | sort -u))
exclude=($(printf "%s\n" "${exclude[@]}" | sort -u))

# 如果没有指定包含，默认包含所有
if [[ ${#include[@]} -eq 0 ]]; then
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

# 按模块编号排序
IFS=$'\n' sorted_modules=($(sort -t: -k1n <<< "${selected_modules[*]}"))
unset IFS

# 执行模块增强
for module in "${sorted_modules[@]}"; do
    IFS=':' read -r num filename message <<< "$module"
    echo
    echo "=== $(get_localized_message "$message") ==="
    if ! load_module "$filename"; then
        exit $?
    fi
done

# 重启提示
echo
read -r -p "$(get_localized_message reboot_prompt) " response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]; then
    reboot
fi

echo
echo "$(get_localized_message goodbye)"
exit 0
