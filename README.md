# GeoPlatform-SDK

GPlatform 底层模块的预编译交付仓库，作为 [GeoPlatform-App](https://github.com/dezbracaty/GeoPlatform-App) 的 Git 子模块使用。
SDK 格式 2 仅包含项目内部库及同次构建的公开/生成头文件、CMake 包配置、对象和自身资源；私有模块的实现源文件留在完整源码主仓库。
第三方依赖由 Root 与 App 共用的 fetch/provider 构建，复用原机器缓存，不进入本 SDK。Qt 由本地开发环境提供。
Base、AppDB、Document 的源码在 App 仓库中，由应用侧编译。

## 目录与版本

```text
AMD64/
└── Release/
    ├── include/
    ├── lib/
    │   └── cmake/GPlatformSDK/
    ├── share/
    ├── objects/
    ├── tools/
    ├── metadata/
    ├── sdk-build.json
    └── sdk-manifest.json
```

App 中的挂载路径为 `ThirdParty/libs/GPlatformSDK/`。
只按 `<架构>/<构建类型>/` 区分产物；版本由 App 的子模块提交指针锁定，不设置版本、平台或工具链目录。
`sdk-build.json` 记录实际编译环境，`sdk-manifest.json` 记录交付文件的 SHA-256。

本轮仅验收 `AMD64/Release`：Windows、MSVC 19.44.35226、Qt 6.11.2、SDK 格式 2。
内部库及其公开头文件、生成头文件、资源来自同一次主项目构建；App 的第三方源码版本和依赖输入必须与 `sdk-build.json` 匹配。
本仓库以当前格式 2 产物重新建立交付历史，旧 Windows/macOS 完整 SDK 不再保留在活动仓库历史中。旧消费者记录的 SDK SHA 需要从迁移归档恢复；新的 macOS 或 Debug 槽须在相应平台重新构建、打包及验收后提供。
Qt 由应用开发环境单独提供；需要使用匹配的架构、构建类型和兼容工具链。

## 获取二进制

库文件通过 Git LFS 管理。先安装 Git LFS，再在 App 仓库执行：

```bash
git lfs install
git submodule update --init --recursive
git -C ThirdParty/libs/GPlatformSDK lfs pull
```

仅下载 GitHub 的源码 ZIP 不能代替上述步骤。编译方法见 [App README](https://github.com/dezbracaty/GeoPlatform-App/tree/fix/sdk-packaging-restart#readme)。
本仓库不包含用于重编私有模块的源码工程。

## 产物维护

在完整源码主仓库中使用 CMake 的 `release` 配置及构建预设，完成 `gplatform_build` 目标。
构建成功后，手动使用唯一的打包脚本处理已有产物：

```bash
python cmake/sdk/publish_sdk.py --export build-Release/sdk-export --output <导出目录>
```

导出目录应位于源码及机器缓存目录之外；该目录包含 `SDK/` 和已携带自身 SDK 的 `App/`。
脚本只处理已构建产物，不初始化子模块、不编译、不提交、不推送、不自动发布。
发布时将导出 `SDK/` 中对应的 `<架构>/<构建类型>/` 槽位完整同步到本仓库，只保留兼容格式 2 的其他槽位。

发布时先提交并推送 SDK 产物及 Git LFS 对象，再更新 App 仓库中的子模块指针。
根目录 README 属于仓库说明，不参与构建产物清单。
应用修改与 SDK 共享的类布局或虚函数接口后，需要发布配套 SDK；当前不保证跨此类修改的二进制兼容性。
