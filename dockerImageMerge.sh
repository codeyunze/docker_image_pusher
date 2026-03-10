#!/bin/bash

# 启用严格模式：出错即退出
set -e

# 镜像管理配置
images_url="registry.cn-guangzhou.aliyuncs.com/devyunze"
images_name="mysql"
images_platform_a="amd64"
images_platform_b="arm64_v8"
images_version="8.0.29"

echo "=================================================="
echo "开始处理镜像: ${images_name}, 版本: ${images_version}"
echo "支持平台: ${images_platform_a}, ${images_platform_b}"
echo "镜像仓库: ${images_url}"
echo "=================================================="

# Step 1: 拉取两个平台的镜像
echo "----- 开始拉取镜像 -----"
docker pull "${images_url}/linux_${images_platform_a}_${images_name}:${images_version}"
docker pull "${images_url}/linux_${images_platform_b}_${images_name}:${images_version}"
echo "----- 镜像拉取完成 -----"

# Step 2: 为镜像打 tag（本地重命名）
echo "----- 开始镜像改名（打标签）-----"
docker image tag "${images_url}/linux_${images_platform_a}_${images_name}:${images_version}" "${images_url}/${images_name}:${images_version}_${images_platform_a}"
docker image tag "${images_url}/linux_${images_platform_b}_${images_name}:${images_version}" "${images_url}/${images_name}:${images_version}_${images_platform_b}"
echo "----- 镜像改名完成 -----"

# Step 3: 推送带平台标签的镜像
echo "----- 开始推送镜像 -----"
docker push "${images_url}/${images_name}:${images_version}_${images_platform_a}"
docker push "${images_url}/${images_name}:${images_version}_${images_platform_b}"
echo "----- 镜像推送完成 -----"

# Step 4: 创建多平台 manifest 清单
echo "----- 开始创建清单（manifest）-----"
docker manifest create \
  "${images_url}/${images_name}:${images_version}" \
  "${images_url}/${images_name}:${images_version}_${images_platform_a}" \
  "${images_url}/${images_name}:${images_version}_${images_platform_b}"
echo "----- 清单创建完成 -----"

# Step 5: 推送 manifest 清单
echo "----- 开始推送清单 -----"
docker manifest push "${images_url}/${images_name}:${images_version}"
echo "----- 清单推送完成 -----"

# Step 6: 清理本地 manifest（可选）
echo "----- 开始清理本地清单 -----"
docker manifest rm "${images_url}/${images_name}:${images_version}" || true
echo "----- 清理本地清单完成 -----"

echo "✅ 所有操作已完成！"