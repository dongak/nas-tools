#!/bin/bash
echo -e "\033[33m欢迎使用 my-drpys 一键安装/更新/删除脚本!\033[0m"

echo -e "\033[31m!!!免责声明!!!\n本脚本仅对道长drpyS项目做技术性测试，脚本作者不生产源，请各位用脚本测试的同学在测试完之后立马删除测试项目。\n任何以该测试脚本来进行非法牟利的，后果自负!\033[0m"

sleep 2

# 自动获取并打印当前路径
current_path=$(pwd)
echo "当前路径为: $current_path"

echo "!!!提醒!!!:请记住映射的drpy-node文件夹就在此目录下"

sleep 3

# 检查是否提供了参数
if [ -z "$1" ]; then
    echo "您当前正在安装/更新 my-drpys !"
else
    echo "您当前正在删除 my-drpys !"
fi

# 等待 2 秒
sleep 2

user_input=$1

if [ "$user_input" = "1" ]; then
    echo "移除容器"
    docker-compose down

    echo "移除映射/执行文件"
    rm -rf drpy-node
    rm -rf docker-compose.yml

    echo "删除镜像"
    docker image prune -a -f

    echo "恭喜你! 删除 my-drpys 成功!"
    exit 0
else
    # 默认执行安装或更新的代码
    copy_env=false  # 标志变量，记录是否拷贝了 env.json

    if [ -d "drpy-node" ]; then
        echo "映射已经存在，等待更新..."

        echo "下载最新版本包..."
        bash -c "$(curl -fsSL https://9764.kstore.vip/drpys/download_drpy-node.sh)"

        if [ ! -f "drpy-node.7z" ]; then
            echo "下载失败，未找到 drpy-node.7z，请稍后再试，脚本退出！"
            exit 1
        fi

        # 检查文件是否存在并拷贝
        if [ -f "drpy-node/config/env.json" ]; then
            echo "拷贝env.json文件..."
            cp drpy-node/config/env.json /tmp/
            copy_env=true  # 标志变量置为 true
        fi

        echo "拷贝授权认证信息..."
        cp drpy-node/.env.development /tmp/
        
        echo "拷贝挂载接口数据"
        cp drpy-node/data/settings/link_data.json /tmp/

        echo "拷贝sub文件夹"
        cp -r drpy-node/public/sub /tmp/

        echo "拷贝sub.md文件"
        cp drpy-node/docs/sub.md /tmp/

        rm -rf drpy-node

        echo "解压最新版本包..."
        sleep 2
        mkdir -p drpy-node && 7z x drpy-node.7z -odrpy-node

        # 删除压缩包
        rm -rf drpy-node.7z

        echo "移除默认sub文件夹"
        rm -rf drpy-node/public/sub

        echo "恢复授权认证信息备份..."
        mv /tmp/.env.development drpy-node/
        
        echo "恢复挂载接口数据备份"
        mv /tmp/link_data.json drpy-node/data/settings/

        echo "恢复sub文件夹备份..."
        mv /tmp/sub drpy-node/public/

        echo "恢复sub.md文件备份..."
        mv /tmp/sub.md drpy-node/docs/

        # 根据标志变量决定是否移动 env.json 文件
        if [ "$copy_env" = true ]; then
            echo "恢复env.json文件..."
            mv /tmp/env.json drpy-node/config/
        fi

        chmod -R 777 "$current_path/drpy-node" && echo "权限修改成功!" || echo "权限修改失败."
    else
        echo "映射不存在，等待安装..."
        
        # 检查是否安装了 7z 解压工具
        if ! command -v 7z &>/dev/null; then
            echo "错误: 未检测到 7z 解压工具，请先安装 7z 后再运行本脚本！"
            echo "Ubuntu/Debian 系统安装命令: sudo apt install p7zip-full -y"
            echo "CentOS 系统安装命令: sudo yum install p7zip -y"
            echo "Arch Linux 系统安装命令: sudo pacman -S p7zip"
            exit 1
        fi

        echo "正在下载最新版本包..."
        bash -c "$(curl -fsSL https://9764.kstore.vip/drpys/download_drpy-node.sh)"

        if [ ! -f "drpy-node.7z" ]; then
            echo "下载失败，未找到 drpy-node.7z，请稍后再试，脚本退出！"
            exit 1
        fi
        
        echo "解压最新版本包..."
        sleep 2
        mkdir -p drpy-node && 7z x drpy-node.7z -odrpy-node

        # 删除压缩包
        rm -rf drpy-node.7z
    fi

    # 等待 2 秒
    sleep 2

    if [ -f "docker-compose.yml" ]; then
        echo "移除容器..."
        docker-compose down

        echo "重新拉取镜像..."
        docker-compose pull

        echo "重新运行容器..."
        docker-compose up -d

        echo "删除旧镜像"
        docker image prune -a -f

        echo "恭喜你更新 my-drpys 成功!"
    else
        echo "yml文件不存在,等待下载..."
        sleep 2
        echo "下载yml文件..."
        wget https://9764.kstore.vip/drpys/docker-compose.yml
        echo "正在安装，请等待..."
        docker-compose up -d
        echo "恭喜你安装 my-drpys 成功!"
    fi

    # 设置权限并提供反馈
    chmod -R 777 "$current_path/drpy-node" && echo "权限修改成功!" || echo "权限修改失败."

    echo "接口提示(请将提示中的ip换成你自己的ip): http://ip:9097/config/1?pwd=这里填写你设置的接口密码"
fi