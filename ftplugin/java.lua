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

-- jdtls 自身需要 Java 21+ 运行（与项目用的 JDK 无关）。系统默认可能是更低版本，
-- 这里用 macOS 的 java_home 解析出一个 21+ 的 JDK，只注入给 jdtls 进程。
local jdtls_java_home
if vim.fn.executable '/usr/libexec/java_home' == 1 then
  local out = vim.fn.system { '/usr/libexec/java_home', '-v', '21+' }
  if vim.v.shell_error == 0 then jdtls_java_home = vim.trim(out) end
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

-- 登记本机可用的 JDK：jdtls server 自身跑在哪个版本无所谓（上面已指 21+），
-- 但分析项目要用项目目标版本的 JDK。列出来后 jdtls 会按项目声明的目标自动选，
-- 避免用 server 运行时 JDK 误当项目 JDK（否则高版本 API 不报错，mvn 编译才炸）。
local runtimes = {}
local function add_runtime(name, home)
  if home and home ~= '' and vim.fn.isdirectory(home) == 1 then table.insert(runtimes, { name = name, path = home }) end
end
add_runtime('JavaSE-17', '/Users/lin/apps/jdk-17.0.12.jdk/Contents/Home')
add_runtime('JavaSE-23', jdtls_java_home)

jdtls.start_or_attach {
  cmd = { jdtls_bin, '-data', workspace },
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
    -- 注册 Java DAP 配置（main class / test），供 <F5>/neotest dap 使用
    pcall(function() require('jdtls.dap').setup_dap_main_class_configs() end)
  end,
}
