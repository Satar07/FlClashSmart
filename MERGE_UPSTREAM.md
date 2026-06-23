# 上游合并指南

下次上游（`chen08209/FlClash`）更新时，对照本指南完成合并和发版。

## 项目结构

合并涉及 **两个仓库、三层代码**：

```
主仓库（Flutter + Go 桥接）
├── origin:  Satar07/FlClashSmart          ← fork 自 chen08209/FlClash
├── upstream: chen08209/FlClash            ← 上游 FlClash
│
├── core/                                 ← Go 桥接层（Flutter ↔ 内核通信）
│   ├── go.mod / go.sum                    ← 依赖 Clash.Meta 子模块
│   ├── hub.go / common.go / action.go …   ← 桥接代码，你和上游都会改
│   │
│   └── Clash.Meta/（子模块）              ← Go 代理内核
│       ├── origin:  Satar07/FlClashCore   ← 直接跟踪 vernesong/mihomo
│       ├── upstream: vernesong/mihomo     ← 开源 Clash.Meta 内核
│       └── 参考:   chen08209/Clash.Meta   ← chen 的 FlClash 接口改动
```

**关键事实**：
- 主仓库你是 chen 的 fork，直接 `git merge upstream/main`
- 子模块你**不是** chen 的 fork，是直接跟踪 mihomo + 手动应用 chen 的 FlClash 接口改动 + 加 Smart Core
- 主仓库 `upstream/main` 指向的子模块 commit（来自 chen），需要 merge 到你的子模块分支

---

## 第 1 步：准备工作

### 任务
确保本地仓库能访问所有必要的远程，并拉取最新代码。

### 注意事项
- 主仓库需要 `upstream`（chen08209/FlClash）的 fetch 权限
- 子模块 `core/Clash.Meta` 里需要能 fetch 到 chen 的 Clash.Meta（主仓库 upstream/main 指向的子模块 commit 在 chen 那边）
- 子模块也需要你的 `cyril` remote（Satar07/FlClashCore），Smart Core 在上面
- fetch 后 `git status` 确认工作区干净，有未提交的改动先 stash

---

## 第 2 步：合并主仓库

### 策略
`git merge upstream/main`，有几个固定冲突区，策略如下：

### 冲突处理

| 文件 | 策略 | 注意 |
|------|------|------|
| `pubspec.yaml` — 版本号 | 上游版本 +1。上游 `0.8.93+xxx` → `0.8.94+<当天日期>01` | 你的版本永远比上游大一号 |
| `pubspec.yaml` — 依赖版本 | 用上游的新版 | 上游一般已经升级好了 |
| `pubspec.lock` | 用上游的，稍后 `flutter pub get` 重新生成 | 解决冲突太麻烦，不如重建 |
| `CHANGELOG.md` | 合并两边条目，你的条目放上面 | |
| `.github/workflows/build.yaml` | **保留你自己的 CI** | 确认 Firebase、`com.flsmart.clash` 没被冲掉；删掉 upstream 新增的 F-Droid 发布步骤 |
| `android/core/build.gradle.kts` | **保留你的 `copyNativeLibs` 任务** | Smart Core 编译需要 |
| Go 桥接文件（`core/*.go`、`core/go.mod`、`core/go.sum`） | 用上游的 | 还在第 3 步子模块合并时会统一处理兼容性 |
| `core/Clash.Meta`（子模块指针） | 暂时用上游的 | 第 3 步会在子模块里重新合并，之后更新指针 |

### 自动合并验证
合并后检查以下内容没被上游覆盖：
- CI 里 Firebase `google-services.json` 步骤在
- 包名是 `com.flsmart.clash`，不是 `com.follow.clash`
- `.gitmodules` 文件还在（指 `core/Clash.Meta` 的 url 是你的 `Satar07/FlClashCore`）

---

## 第 3 步：合并子模块（最复杂）

### 背景
主仓库 `upstream/main` 指向的子模块 commit 来自 chen08209/Clash.Meta，包含 chen 的 FlClash 接口改动。你的子模块（Satar07/FlClashCore）直接基于 mihomo + Smart Core。这一步把 chen 的改动并进来。

### 策略
在你的子模块中，把你 Smart Core 分支和上游主仓库指向的 commit 做 merge：

```
你的 cyril/Alpha（或 Alpha 分支）    ← Smart Core + mihomo
        merge
上游主仓库指向的子模块 commit          ← chen 的 FlClash 接口 + 新版 mihomo
```

### 任务
1. 在子模块里基于你的 Smart Core 分支创建临时合并分支
2. merge 上游主仓库 `upstream/main` 指向的子模块 commit
3. 解决冲突（策略见下）
4. commit 合并结果

### 冲突处理

| 文件 | 策略 |
|------|------|
| `.github/workflows/*`（子模块内 CI） | 保留你的 |
| `adapter/outboundgroup/loadbalance.go` | 保留你的 |
| `adapter/outboundgroup/parser.go` | 确认 `case "smart"` 还在 |
| `component/profile/cachefile/cache.go` | 保留你的，后面可能需要补常量 |
| `go.mod` | **手动合并**：保留 `vernesong/leaves`（Smart 推理依赖），其余用上游新版 |
| `hub/executor/executor.go` | 保留你的 |
| `main.go` | 保留你的 |
| `tunnel/statistic/*` | 保留你的 |
| `listener/sing_tun/server_android.go` | 如果被删了但上游有修改，取上游的 |

### 保留住这些 Smart Core 文件
合并时确认以下文件没有被删或覆盖：
- `adapter/outboundgroup/smart.go`
- `component/smart/` 整个目录
- `component/profile/cachefile/smart_cache.go`
- `constant/adapters.go` 中的 `C.Smart` 类型定义

---

## 第 4 步：修复 Go 编译错误

子模块合并后大概率有编译错误。先跑 `go mod tidy`（注意**两层都要**），然后编译：

### go mod tidy

**注意顺序和层级**：
1. 先子模块：`core/Clash.Meta/` 里跑 `go mod tidy`
2. 再外层：`core/` 里跑 `go mod tidy`
3. 验证外层的 `core/go.sum` 里有 `vernesong/leaves` 的条目

### 常见编译错误

| 错误特征 | 原因 | 修复 |
|------|------|------|
| `undefined: bucketStorage` | 上游新增 `storage.go` 引用了这个常量，你的 `cache.go` 没定义 | 在 `component/profile/cachefile/cache.go` 的 var 块中加 `bucketStorage = []byte("storage")` |
| `*LoadBalance does not implement ProxyGroup (Hidden is a field, not a method)` | 你的 `LoadBalance` 有 `Hidden bool` 字段，遮盖了 `GroupBase.Hidden()` 方法。上游把接口从字段改成了方法 | 删除 `LoadBalance` 和 `Smart` 结构体中的 `Hidden`、`Icon` 字段；MarshalJSON 改为方法调用 `lb.Hidden()`；构造函数中把 `Hidden`/`Icon` 传入 `GroupBaseOption` |
| `NowTraffic / TotalTraffic undefined` | 上游 API 改名：`NowTraffic(bool)` → `Now()`，去掉了参数 | 在 `core/hub.go` 中改为无参调用 |
| `missing go.sum entry for vernesong/leaves` | go.sum 缺条目 | 确保两层都跑了 `go mod tidy` |
| `.gitmodules` 被删除 | merge 自动处理可能误删 | 从 merge 前的 commit 恢复：`git checkout HEAD~1 -- .gitmodules`，然后 `git submodule update --init` |

---

## 第 5 步：更新主仓库子模块指针

子模块合并 commit 完成后，回到主仓库，把 `core/Clash.Meta` 指向你的合并 commit：

```
git add core/Clash.Meta
git commit -m "chore: update submodule after upstream merge"
```

---

## 第 6 步：编译和验证

### 编译
```bash
flutter pub get
flutter build apk --release
```

### Smart 功能验证清单

编译通过后，检查以下内容：

- [ ] `assets/data/Model.bin` 存在（预下载模型）
- [ ] `lib/common/constant.dart` 有 `MODEL = 'Model.bin'` 和 `packageName = 'com.flsmart.clash'`
- [ ] `lib/views/resources.dart` 的 geoItems 列表有 MODEL
- [ ] `lib/core/controller.dart` 的 `geoFileNameList` 包含 `MODEL`
- [ ] `android/core/build.gradle.kts` 有 `copyNativeLibs` 任务
- [ ] CI 文件有 Firebase 和 `com.flsmart.clash`，没有 F-Droid
- [ ] 子模块 `adapter/outboundgroup/parser.go` 有 `case "smart"`
- [ ] 子模块 `component/smart/` 目录存在
- [ ] ADB 安装到手机，Smart 功能正常

---

## 快速参考：文件职责

| 文件/目录 | 谁在改 | 合并策略 |
|-----------|--------|----------|
| `pubspec.yaml` | 双方 | 版本 +1，依赖跟上流 |
| `.github/workflows/build.yaml` | 双方 | **保留自己的** |
| `android/core/build.gradle.kts` | 你 | **保留自己的** |
| `core/hub.go`, `core/common.go` … | 双方 | 跟上流，子模块 merge 后修兼容 |
| `core/go.mod`, `core/go.sum` | 双方 | 跟上流 + go mod tidy |
| `core/Clash.Meta/` 子模块 | 三方（mihomo、chen、你） | merge chen 的 commit 到你的分支 |
| `core/Clash.Meta/adapter/outboundgroup/smart.go` | 你 | **不能丢** |
| `core/Clash.Meta/component/smart/` | 你 | **不能丢** |
| `lib/common/constant.dart` | 双方 | 保留你的 MODEL 和 packageName |
| `assets/data/Model.bin` | 你 | **不能丢** |
