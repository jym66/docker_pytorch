# 使用 PyTorch 的基础镜像
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# 安装 SSH 服务和必需的包，配置 SSH，更新 Conda，设置国内软件源，安装科学计算和深度学习库，配置 pip 源
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    conda update -n base -c defaults conda && \
    conda install -y numpy scipy matplotlib scikit-learn pandas sympy seaborn statsmodels transformers safetensors && \
    conda clean -afy && \
    sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//g' /etc/apt/sources.list && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main && \
    conda config --set show_channel_urls yes && \
    pip install --upgrade pip && \
    pip install --no-cache-dir torchlibrosa wandb accelerate&& \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 添加 SSH 公钥并设置文件权限
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys && \
    chown root:root /root/.ssh/authorized_keys

# 复制启动 SSH 服务的脚本到容器并设置执行权限
COPY start_sshd.sh /usr/local/bin/start_sshd.sh
RUN chmod +x /usr/local/bin/start_sshd.sh

# 将环境变量自动加载添加到 .bashrc
RUN echo 'if [ -f /etc/environment ]; then set -a; source /etc/environment; set +a; fi' >> /root/.bashrc

# 开放 22 端口供 SSH 使用
EXPOSE 22

# 使用自定义脚本启动 SSH 服务
CMD ["/usr/local/bin/start_sshd.sh"]
