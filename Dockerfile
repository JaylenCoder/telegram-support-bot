# 基础镜像：Python 3.13 精简版
FROM python:3.13-slim

# 从官方镜像复制 uv 二进制，无需 pip 安装
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /app

# 先复制依赖清单，利用层缓存加速重复构建
COPY requirements.txt .

# 使用 uv 安装依赖（基于 Rust 实现，比 pip 快 10-100 倍）
RUN uv pip install --system --no-cache -r requirements.txt

# 复制项目代码
COPY main.py handlers.py settings.py ./

# 以非 root 用户运行，提升安全性
RUN useradd --create-home botuser && chown -R botuser:botuser /app
USER botuser

CMD ["python", "main.py"]
