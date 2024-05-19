# 使用 PyTorch 的基础镜像
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# 安装 SSH 服务和必需的包，配置 SSH，更新 Conda，安装科学计算库
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
    conda config --set show_channel_urls yes

# 添加公钥
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys && \
    chown root:root /root/.ssh/authorized_keys

# 更新 pip 和安装其他 Python 包
RUN pip install --upgrade pip && \
    pip install --no-cache-dir torchlibrosa wandb

# 配置 SSH 登录时执行命令
RUN echo 'export $(cat /proc/1/environ | tr "\\0" "\\n" | xargs)' >> /root/.bashrc

# 开放 22 端口
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]
