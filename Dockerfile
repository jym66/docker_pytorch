# 使用 PyTorch 的基础镜像
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# 安装 SSH 服务和必需的包，配置 SSH，更新 Conda，安装科学计算库，并清理缓存
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh && \
    conda update -n base -c defaults conda && \
    conda install -y numpy scipy matplotlib scikit-learn pandas sympy seaborn statsmodels transformers safetensors && \
    conda clean -afy && \
    sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//g' /etc/apt/sources.list && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main && \
    conda config --set show_channel_urls yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 添加公钥
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys && \
    chown root:root /root/.ssh/authorized_keys

# 更新 pip 和安装其他 Python 包，并清理 pip 缓存
RUN pip install --upgrade pip && \
    pip install --no-cache-dir torchlibrosa wandb

# 复制 start_sshd.sh 脚本到容器中并赋予执行权限
COPY start_sshd.sh /usr/local/bin/start_sshd.sh
RUN chmod +x /usr/local/bin/start_sshd.sh

# 自动将环境变量加载逻辑添加到 /root/.bashrc
RUN echo 'if [ -f /etc/environment ]; then set -a; source /etc/environment; set +a; fi' >> /root/.bashrc

# 开放 22 端口
EXPOSE 22

# 使用自定义启动脚本来启动 SSH
CMD ["/usr/local/bin/start_sshd.sh"]
