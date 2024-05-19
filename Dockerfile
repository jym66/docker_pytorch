# 使用 PyTorch 的基础镜像
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# 安装 SSH 服务和必需的包
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

# 禁用密码登录，启用密钥登录
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 添加你的公钥到 authorized_keys
RUN mkdir -p /root/.ssh
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys

# 更新 Conda
RUN conda update -n base -c defaults conda

# 更新 pip
RUN pip install --upgrade pip

# 使用 Conda 安装科学计算库
RUN conda install -y numpy scipy matplotlib scikit-learn pandas sympy seaborn statsmodels transformers safetensors

# 使用 pip 安装 torchlibrosa 和 wandb
RUN pip install torchlibrosa wandb

# 设置 Ubuntu 镜像源为国内镜像（例如使用清华大学的镜像源）
RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//g' /etc/apt/sources.list

# 配置 Conda 使用国内镜像源
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
RUN conda config --set show_channel_urls yes

# 配置 SSH 登录时执行命令
RUN echo 'export $(cat /proc/1/environ | tr "\\0" "\\n" | xargs)' >> /root/.bashrc

# 开放 22 端口
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]
