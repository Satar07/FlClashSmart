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
│   ├── hub.go / common.go / lib.go …      ← 桥接代码
│   │
│   └── Clash.Meta/（子模块）              ← Go 代理内核
│       ├── origin:  Satar07/FlClashCore   ← Smart 内核 fork
│       ├── vernesong: vernesong/mihomo    ← Smart 内核上游（Alpha 分支，含 LightGBM/leaves）
│       ├── chen:  chen08209/Clash.Meta    ← FlClash 适配补丁来源（GeoUpdateHook 等）
```

**关键事实**：
- Core 子模块：跟踪 vernesong/mihomo（Smart 内核）+ 1 个 FlClash 适配 commit（`FlClash-smart-rebase` 分支）
- 主仓库：跟踪 chen08209/FlClash + 3 个 Smart 补丁 commit（`smart` 分支）
- 两边都是 rebase，不是 merge
- 子模块适配 commit 里同时包含 Smart 内核能力（LightGBM/leaves）和 FlClash 适配（GeoUpdateHook、per-proxy 流量等），两者缺一不可

---

## 前置：子模块 remote 必须是 https

SSH 在某些网络下会被拦截（`Connection closed by ... port 22`）。确保三个 remote 都是 https：

```bash
cd core/Clash.Meta
git remote set-url origin https://github.com/Satar07/FlClashCore.git
git remote set-url vernesong https://github.com/vernesong/mihomo.git
git remote set-url chen https://github.com/chen08209/Clash.Meta.git
```

## Core 子模块更新（vernesong/mihomo 有新版本时）

```bash
cd core/Clash.Meta
git fetch vernesong Alpha
git rebase vernesong/Alpha        # 把 FlClash 适配补丁挪到最新 Smart 内核上
```

- 只有 1 个适配 commit，冲突范围明确（`*patch*.go`、`component/updater/`、Android 文件）
- 冲突时参考：**保留 Smart 内核能力（LightGBM/leaves）+ 贴近 FlClash 适配逻辑**，适配 mihomo 的新 API
- 特别注意：FlClash 适配需要的 `updater.GeoUpdateHook` / `RegisterGeoUpdaterWithCancel`（在 `component/updater/patch.go`）必须保留，否则 `core/hub.go`、`core/common.go` 会 undefined
- rebase 完成后 `go mod tidy`，然后主仓库更新子模块指针

## 主仓库更新（FlClash 上游有新版本时）

```bash
git fetch upstream                 # upstream = chen08209/FlClash
git rebase upstream/main           # 把 3 个 Smart commit 挪到最新 FlClash 上
```

Smart 补丁结构（从上到下，rebase 后依次 apply）：

| 顺序 | Commit | 内容 | 冲突风险 |
|------|--------|------|---------|
| 1 | `feat: Smart Core integration` | Model.bin、hub.go、controller、config 字段、`GeoResource.MODEL`、3 个子模块指针 | 低（独立文件为主，但依赖子模块指针一致） |
| 2 | `chore: rename package + Smart build config and CI` | 全部 Android 包名替换、CI workflow、Gradle 配置、平台配置 | 高（upstream 重构 Android 进程架构会大冲突） |
| 3 | `docs: rebase workflow guide` | CLAUDE.md、REBASE_UPSTREAM.md、README | 低 |

### 冲突处理要点

| 文件 | 策略 |
|------|------|
| `pubspec.yaml` | 版本号用上游 +1；依赖用上游新版 |
| `.github/workflows/build.yaml` | **保留 Smart 的 CI**（`ref: smart`、移除 changelog 自动生成 job） |
| `android/*/build.gradle.kts` | **保留 Smart 的配置**（`namespace`/`applicationId` 为 `com.flsmart.clash`） |
| `core/Clash.Meta` | **保留 Smart 的子模块指针**（指向 FlClashCore 的 `FlClash-smart-rebase`） |
| 所有 `com.follow.clash` vs `com.flsmart.clash` | 用 `com.flsmart.clash` |
| `lib/enum/enum.dart` 的 `GeoResource` | 保留 `MODEL` 枚举值（`@JsonValue('model')`） |
| `lib/models/clash_config.dart` | `defaultGeoXUrl` 保留 `GeoResource.MODEL` 的 Model.bin URL |

### Rebase 后

```bash
# 同步 Go 依赖
cd core && go mod tidy && cd ..
cd core/Clash.Meta && go mod tidy && cd ../..

# 构建验证
flutter pub get
flutter analyze --no-fatal-infos
flutter build apk --debug --target-platform android-arm64
```

---

## Smart 功能验证清单

编译通过后检查：

- [ ] `assets/data/Model.bin` 存在
- [ ] `lib/common/constant.dart` 有 `MODEL = 'Model.bin'` 和 `packageName = 'com.flsmart.clash'`
- [ ] `lib/enum/enum.dart` 的 `GeoResource` 枚举含 `MODEL`（`@JsonValue('model')`）
- [ ] `lib/models/clash_config.dart` 的 `defaultGeoXUrl` 含 `GeoResource.MODEL`
- [ ] `lib/views/resources.dart` 的 `_GeoResourceListItemState.fileName` 有 `GeoResource.MODEL => MODEL`
- [ ] CI 文件有 `ref: smart` 和 `com.flsmart.clash`
- [ ] 子模块 `adapter/outboundgroup/parser.go` 有 `case "smart"`
- [ ] 子模块 `component/smart/` 目录存在
- [ ] 子模块 `component/updater/patch.go` 有 `GeoUpdateHook` 和 `RegisterGeoUpdaterWithCancel`
- [ ] ADB 安装到手机，Smart 功能正常
