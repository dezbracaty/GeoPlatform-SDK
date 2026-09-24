# GeoPlatform-SDK

GPlatform 底层模块的预编译交付仓库，作为 [GeoPlatform-App](https://github.com/dezbracaty/GeoPlatform-App) 的 Git 子模块使用。
包含编译所需头文件、库、CMake 包配置及运行资源；私有模块的实现源文件留在完整源码主仓库。
Base、AppDB、Document 的源码在 App 仓库中，由应用侧编译。

## 目录与版本

```text
arm64/
└── Release/
    ├── include/
    ├── lib/
    │   └── cmake/GPlatformSDK/
    ├── resources/
    ├── sdk-build.json
    └── sdk-manifest.json
```

App 中的挂载路径为 `ThirdParty/libs/GPlatformSDK/`。
只按 `<架构>/<构建类型>/` 区分产物；版本由 App 的子模块提交指针锁定，不设置版本、平台或工具链目录。
`sdk-build.json` 记录实际编译环境，`sdk-manifest.json` 记录交付文件的 SHA-256。

当前交付 `arm64/Release`：macOS、最低 macOS 15、AppleClang 21、Qt 6.9.3。
Qt 由应用开发环境单独提供；需要使用匹配的架构、构建类型和兼容工具链。

## 获取二进制

库文件通过 Git LFS 管理。先安装 Git LFS，再在 App 仓库执行：

```bash
git lfs install
git submodule update --init --recursive
git -C ThirdParty/libs/GPlatformSDK lfs pull
```

仅下载 GitHub 的源码 ZIP 不能代替上述步骤。编译方法见 [App README](https://github.com/dezbracaty/GeoPlatform-App#readme)。
本仓库不包含用于重编私有模块的源码工程。

## 产物维护

在完整源码主仓库中启用 `GPLATFORM_SYNC_SDK=ON`，使用 CMake 的 `gplatform_build` 目标编译。
成功后，`gplatform_sdk_sync` 自动同步产物到 SDK 子模块；无变化的文件保持不变。
同步过程不自动提交或推送 Git。

发布时先提交并推送 SDK 产物及 Git LFS 对象，再更新 App 仓库中的子模块指针。
根目录 README 属于仓库说明，不参与构建产物清单，SDK 同步会保留该文件。
应用修改与 SDK 共享的类布局或虚函数接口后，需要发布配套 SDK；当前不保证跨此类修改的二进制兼容性。
