-- ftplugin/java.lua
-- 每次打开 Java buffer 时被 source，为当前项目启动 / 附着一个 jdtls 客户端。
-- 这是 nvim-jdtls 的标准用法（jdtls 按项目根启动，不走 vim.lsp.enable）。
-- 依赖 mason 安装的 jdtls / java-debug-adapter / java-test（见 init.lua ensure_installed）。

local ok, jdtls = pcall(require, 'jdtls')
if not ok then return end -- nvim-jdtls 尚未安装（首次启动 mason 还在拉取），静默跳过

local mason = vim.fn.stdpath 'data' .. '/mason'

-- jdtls 启动器：mason 的 wrapper 脚本，已内置 java + launcher jar + 平台 config 参数
local jdtls_bin = mason .. '/bin/jdtls'
if vim.fn.executable(jdtls_bin) ~= 1 then return end -- 还没装好，等下次打开

-- 自动发现本机 JDK：扫描常见安装目录，读每个 JDK 自带的 release 文件解析主版本号，
-- 登记为 JavaSE-<major>。装/删 JDK 后无需改本文件——重开 nvim 即自动生效。
-- 想加新的安装位置只需往 jdk_globs 里加一条 glob。
-- 注意：路径里的 * 交给下面的 vim.fn.glob 展开，这里只把 $HOME 拼进去。
-- 不要用 vim.fn.expand('~/.../*/...')——expand 会把 * 一起展开成多行，
-- 再喂给 glob 就匹配不到了（多个 JDK 时静默返回空）。
local jdk_globs = {
  vim.env.HOME .. '/Library/Java/JavaVirtualMachines/*/Contents/Home', -- 用户级（IDE 下载 / 手动解压）
  '/Library/Java/JavaVirtualMachines/*/Contents/Home', -- 系统级（pkg/dmg 安装器）
}
-- 从 JDK 的 release 文件解析 Java 主版本号（8 → 8，17 → 17，1.8 老式 → 8）
local function jdk_major(home)
  local rel = home .. '/release'
  if vim.fn.filereadable(rel) ~= 1 then return nil end
  for _, line in ipairs(vim.fn.readfile(rel)) do
    local ver = line:match '^JAVA_VERSION="([^"]+)"'
    if ver then
      local a, b = ver:match '^(%d+)%.(%d+)'
      if not a then a = ver:match '^(%d+)' end
      a, b = tonumber(a), tonumber(b)
      if a == 1 and b then return b end -- 1.8 → 8
      return a
    end
  end
end

-- 登记本机可用的 JDK：分析项目要用项目声明的目标版本的 JDK。列出来后 jdtls 按项目目标
-- 自动选，避免用 server 运行时 JDK 误当项目 JDK（否则高版本 API 不报错，mvn 编译才炸）。
-- 只是登记，不预加载：某版本 JDK 只在真有该目标版本的项目时才被索引。
local runtimes, seen = {}, {}
for _, glob in ipairs(jdk_globs) do
  for _, home in ipairs(vim.fn.glob(glob, true, true)) do
    if vim.fn.isdirectory(home) == 1 and vim.fn.executable(home .. '/bin/java') == 1 then
      local m = jdk_major(home)
      if m and not seen[m] then
        seen[m] = true
        table.insert(runtimes, { name = m <= 8 and ('JavaSE-1.' .. m) or ('JavaSE-' .. m), path = home })
      end
    end
  end
end

-- jdtls server 自身需要 Java 21+ 运行（与项目用的 JDK 无关）：从上面发现的 JDK 里挑
-- 最高的一个 21+，只注入给 jdtls 进程。
local jdtls_java_home
do
  local best = 0
  for _, rt in ipairs(runtimes) do
    local m = tonumber(rt.name:match '(%d+)$')
    if m and m >= 21 and m > best then best, jdtls_java_home = m, rt.path end
  end
end

-- 项目根：优先构建工具标记，退回 .git，再退回 cwd
local root = vim.fs.root(0, { 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' }) or vim.fn.getcwd()

-- 每个项目独立的 workspace，避免跨项目状态污染
local project_name = vim.fn.fnamemodify(root, ':p:h:t')
local workspace = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

-- 收集 DAP / 测试 bundle：java-debug-adapter 提供调试，java-test 提供 JUnit 运行/发现
local bundles = {}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. '/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true), '\n'))
-- java-test 的全部 server jar，但排除 runner 自身（nvim-jdtls 文档要求）
for _, jar in ipairs(vim.split(vim.fn.glob(mason .. '/packages/java-test/extension/server/*.jar', true), '\n')) do
  if jar ~= '' and not jar:match 'com.microsoft.java.test.runner%-jar%-with%-dependencies' then table.insert(bundles, jar) end
end
bundles = vim.tbl_filter(function(j) return j ~= '' end, bundles)

-- Lombok agent: 让 jdtls 识别 @Data/@Getter 等注解生成的方法，否则字段全报 unused
local lombok_jar = mason .. '/packages/jdtls/lombok.jar'

jdtls.start_or_attach {
  cmd = { jdtls_bin, '-data', workspace, '--jvm-arg=-javaagent:' .. lombok_jar },
  cmd_env = jdtls_java_home and { JAVA_HOME = jdtls_java_home } or nil,
  root_dir = root,
  init_options = { bundles = bundles },
  settings = {
    java = {
      -- 保存时不阻塞、允许增量编译；其余用 jdtls 默认
      configuration = {
        updateBuildConfiguration = 'interactive',
        runtimes = runtimes,
      },
    },
  },
  on_attach = function()
    -- Register the Java DAP adapter (dap.adapters.java). Required to run/debug
    -- main methods and tests; without it dap.continue() errors "adapter java not found".
    --
    -- config_overrides applies to every discovered config (becomes default_config_overrides):
    --   console = 'internalConsole' — jdtls defaults discovered configs to
    --   integratedTerminal, whose runInTerminal handshake times out under nvim-dap +
    --   dapui terminal redirection ("Failed to launch debuggee in terminal: Timeout").
    --   internalConsole routes program output via DAP output events into the repl instead.
    -- Env vars are NOT set here: they're inherited from nvim's process environment, which
    -- the dotenv plugin loads from the project's .env on entering the dir. So the
    -- auto-discovered run config just works, no per-config env needed.
    pcall(function()
      require('jdtls').setup_dap {
        hotcodereplace = 'auto',
        config_overrides = { console = 'internalConsole' },
      }
    end)
    -- Eagerly discover main-class run configs, so <leader>dd runs directly (no picker
    -- when there's a single main) and <leader>dr can reference dap.configurations.java[1].
    -- This also disables the lazy provider that setup_dap registered (nvim-jdtls does it
    -- internally), so the config list won't be duplicated.
    --
    -- Pass config_overrides HERE directly (not only on setup_dap): setup_dap has an early
    -- `if dap.adapters.java then return end`, so once the adapter is registered its
    -- config_overrides is never refreshed. Discovered configs default to integratedTerminal,
    -- whose runInTerminal handshake times out under dapui; force internalConsole so program
    -- output flows via DAP output events into the repl instead. fetch_main_configs uses
    -- opts.config_overrides directly, so passing it here always takes effect.
    pcall(function()
      require('jdtls.dap').setup_dap_main_class_configs {
        config_overrides = { console = 'internalConsole' },
      }
    end)
  end,
}
