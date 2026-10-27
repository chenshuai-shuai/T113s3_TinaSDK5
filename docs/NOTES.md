# T113s3 Tina5 SDK 板级改动仓

## 底座 SDK
- 包名: 100ASK_T113s3-PRO_TinaSDK5 (Tina5, kernel 5.4.61, 芯片 t113 / sun8iw20p1)
- 补丁: 未应用 100ask 的 T113-PRO 扩展包 (无 100ask 实物板)

## 底座包校验 (md5, 三个分片)
35577ee74334ee8bd9c5fcca844795b3  100ASK_T113s3-PRO_TinaSDK5.tar.gz.00
3420eef596165883cde2e14a41a12358   ...tar.gz.01
ad730f3b76e3943652b56c8c5335f52c   ...tar.gz.02
拼接解压: cat 100ASK_T113s3-PRO_TinaSDK5.tar.gz.0* | tar -xzf -

## 本仓库范围
只做版本管理以下内容, SDK 本体 (25~30G, 含闭源 bin) 不入库:
- device/config/chips/t113/configs/<board>/   板级三件套 board.dts / sys_config.fex / sys_partition.fex
- docs/                                       笔记
- patches/                                    对 kernel/u-boot 源码的改动 (git diff 导出)
- scripts/                                    辅助脚本

## 编译环境 (家中 VMware Ubuntu 20.04)
- git 2.25.1 (无 -b 选项, 用 git checkout -b main)
- 内存 5.7G + swap 12G -> 必须 export MAKEFLAGS=-j4
- 板型: ./build.sh config -> linux / buildroot / t113 / <board> / default
