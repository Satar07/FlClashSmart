# 上游更新指南（Rebase 流程）

下次上游更新时，用 rebase 方式把 Smart 补丁挪到最新版上，而不是 merge。

## 项目结构

```
主仓库 FlClashSmart（Flutter + Go 桥接）
├── origin:  Satar07/FlClashSmart          ← fork 自 chen08209/FlClash
├── upstream: chen08209/FlClash            ← 上游 FlClash
│
├── core/                                 ← Go 桥接层（FFI/socket 通信）
│   ├── go.mod / go.sum                    ← 依赖 Clash.Meta 子模块
│   ├── hub.go / common.go / action.go …   ← 桥接代码
│   │
│   └── Clash.Meta/（子模块）              ← Go 代理内核
│       ├── origin:  Satar07/FlClashCore   ← 直接跟踪 vernesong/mihomo
│       ├── upstream: vernesong/mihomo     ← mihomo 内核（Alpha 分支）
```

**关键事实**：
- Core 子模块：直接跟踪 mihomo + 1 个 FlClash 适配 commit（`FlClash-smart-rebase` 分支）
- 主仓库：跟踪 chen08209/FlClash + 4 个 Smart 补丁 commit（`smart` 分支）
- 两边都是 rebase，不是 merge

---

## Core 子模块更新（mihomo 有新版本时）

```bash
cd core/Clash.Meta
git fetch origin              # origin = vernesong/mihomo
git rebase origin/Alpha       # 把 FlClash 适配补丁挪到最新 mihomo 上
```

- 只有 1 个 commit，冲突范围明确（`*patch*.go`、Android 文件）
- 冲突时参考：保留 FlClash 的适配逻辑 + 适配 mihomo 的新 API
- rebase 完成后 `go mod tidy`

## 主仓库更新（FlClash 上游有新版本时）

```bash
git fetch upstream            # upstream = chen08209/FlClash
git rebase upstream/main      # 把 4 个 Smart commit 挪到最新 FlClash 上
```

Smart 补丁结构（从上到下，rebase 后依次 apply）：

| 顺序 | Commit | 内容 | 冲突风险 |
|------|--------|------|---------|
| 1 | `feat: Smart Core integration` | Model.bin、hub.go、controller、config 字段、子模块指针 | 低（独立文件为主） |
| 2 | `chore: rename package com.follow → com.flsmart` | 全部 Android 文件包名替换 | 中（上游改动同文件会冲突） |
| 3 | `chore: Smart build config and CI` | CI workflow、Gradle 配置、平台配置、文档 | 中（CI 文件双方都改） |
| 4 | `chore: sync dependencies` | go mod tidy 结果 | 每次 rebase 后重新生成 |

### 冲突处理要点

| 文件 | 策略 |
|------|------|
| `pubspec.yaml` | 版本号用上游 +1；依赖用上游新版 |
| `.github/workflows/build.yaml` | **保留 Smart 的 CI**（Firebase、`com.flsmart.clash`） |
| `android/*/build.gradle.kts` | **保留 Smart 的配置**（`copyNativeLibs` 任务等） |
| `core/Clash.Meta` | **保留 Smart 的子模块指针**（指向你的 FlClashCore） |
| 所有 `com.follow.clash` vs `com.flsmart.clash` | 用 `com.flsmart.clash` |

### Rebase 后

```bash
# 同步 Go 依赖
cd core && go mod tidy && cd ..
cd core/Clash.Meta && go mod tidy && cd ../..

# 构建验证
flutter pub get
flutter build apk --debug --target-platform android-arm64
```

---

## Smart 功能验证清单

编译通过后检查：

- [ ] `assets/data/Model.bin` 存在
- [ ] `lib/common/constant.dart` 有 `MODEL = 'Model.bin'` 和 `packageName = 'com.flsmart.clash'`
- [ ] `lib/views/resources.dart` 的 geoItems 列表有 MODEL
- [ ] CI 文件有 Firebase 和 `com.flsmart.clash`
- [ ] 子模块 `adapter/outboundgroup/parser.go` 有 `case "smart"`
- [ ] 子模块 `component/smart/` 目录存在
- [ ] ADB 安装到手机，Smart 功能正常
