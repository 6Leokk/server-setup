好的，这是修改后的 README.zh-CN.md 文档，添加了参考/致谢部分，并进一步规范化了内容：


# 🛠️ Server-Setup 服务器初始化工具

<!-- 
建议在此处添加一个横幅图片，例如：
![Server Setup](https://your-image-hosting.com/server-setup-banner.png)
-->

![License](https://img.shields.io/badge/License-MIT-blue)
![Platform](https://img.shields.io/badge/Support-Debian%20|%20Ubuntu%20|%20RHEL%20|%20CentOS-red)
![Shell](https://img.shields.io/badge/Shell-Bash%205.0+-green)

一站式服务器初始化解决方案，提供模块化配置和快速部署能力，支持主流的Linux发行版。

## 📋 功能特性

| 模块功能               | 描述                          | Debian系 | RedHat系 |
| :--------------------- | :---------------------------- | :------: | :------: |
| **系统基础配置**        |                               |          |          |
| 系统语言设置           | 配置本地化语言环境              |    ✅    |    ✅    |
| 软件源镜像             | 替换国内软件源加速              |    ✅    |    ✅    |
| 系统全量更新           | 更新系统及所有软件包            |    ✅    |    ✅    |
| **输入法支持**          |                               |          |          |
| Fcitx框架+Rime输入法   | 安装配置中文（薄荷拼音）输入法      |    ✅    |    ❌    |
| IBus框架+Rime输入法    | 安装配置中文（薄荷拼音）输入法    |    ❌    |    ✅    |
| **容器环境**            |                               |          |          |
| Docker引擎安装         | 安装最新版Docker-CE            |    ✅    |    ✅    |
| Docker镜像加速         | 配置国内镜像仓库加速            |    ✅    |    ✅    |

## 🚀 快速安装

### 方法一：在线安装（推荐）

```bash
# Debian/Ubuntu
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourname/server-setup/main/install_debian.sh)"

# RHEL/CentOS
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourname/server-setup/main/install_redhat.sh)"
```

### 方法二：手动安装

```bash
# 下载项目ZIP包并解压
wget https://github.com/yourname/server-setup/archive/refs/heads/main.zip
unzip main.zip && cd server-setup-main

# 授权执行权限
chmod +x install_*.sh

# 执行对应系统脚本
sudo ./install_debian.sh  # Debian/Ubuntu
sudo ./install_redhat.sh  # RHEL/CentOS
```

## 🧩 模块架构

```text
server_setup/
├── install_debian.sh       # Debian系列主脚本
├── install_redhat.sh       # RedHat系列主脚本
└── modules/
    ├── debian/
    │   ├── 01_system_lang.sh
    │   ├── 02_software_sources.sh
    │   ├── 03_system_update.sh
    │   ├── 04_fcitx_rime.sh
    │   ├── 05_docker_setup.sh
    │   └── 06_docker_mirror.sh
    └── redhat/
        ├── 01_system_lang.sh
        ├── 02_software_sources.sh
        ├── 03_system_update.sh
        ├── 04_fcitx_rime.sh
        ├── 05_docker_setup.sh
        └── 06_docker_mirror.sh

```

## 🔧 自定义配置

1.  **模块管理**

    *   添加新模块：在对应发行版目录创建`NN_module.sh`文件
    *   禁用模块：移除或重命名模块文件
    *   执行顺序：按文件名数字序号顺序执行

2.  **配置调整**

    ```bash
    # 修改软件源镜像地址
    vim modules/debian/02_software_sources.sh

    # 调整Docker镜像加速器
    vim modules/*/06_docker_mirror.sh
    ```

## 🤝 参与贡献

欢迎通过以下方式参与项目：

1.  提交Issues报告问题或建议
2.  Fork仓库并提交Pull Request
3.  完善文档或添加测试用例

**开发规范：**

*   使用ShellCheck验证脚本语法
*   模块间保持独立性
*   添加详细的执行日志

## 🙏 参考/致谢

*   **Rime 输入法引擎：** [https://rime.im/](https://rime.im/)
*   **薄荷输入法 (Mint Input Method)：**  (如果薄荷输入法有特定主页或仓库，请在此处添加链接)
*   其他可能需要致谢的项目或资源...

## 📜 许可证

本项目采用 [MIT License](LICENSE) 开源协议

---

> 🌟 **提示**：建议在全新系统环境中执行脚本，生产环境请先做好备份！


