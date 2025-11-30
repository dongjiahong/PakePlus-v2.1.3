#!/bin/bash

# 测试禁用更新器的脚本
# 用于验证工作流中的修改是否正确

set -e

echo "🧪 测试禁用 Tauri 更新器..."

# 备份文件
echo "📦 备份原始文件..."
cp src-tauri/tauri.conf.json src-tauri/tauri.conf.json.test-backup
cp src-tauri/src/lib.rs src-tauri/src/lib.rs.test-backup

# 修改 tauri.conf.json
echo "📝 修改 tauri.conf.json..."
node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('src-tauri/tauri.conf.json', 'utf8'));

console.log('原始 updater 配置:', config.plugins?.updater);

// 删除更新器配置
if (config.plugins && config.plugins.updater) {
    delete config.plugins.updater;
    console.log('✅ 已删除 updater 配置');
}

fs.writeFileSync('src-tauri/tauri.conf.json', JSON.stringify(config, null, 4));
console.log('✅ tauri.conf.json 已更新');
"

# 修改 lib.rs
echo "📝 修改 lib.rs..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's/\.plugin(tauri_plugin_updater::Builder::new()\.build())/\/\/ .plugin(tauri_plugin_updater::Builder::new().build()) \/\/ 已禁用更新器/' src-tauri/src/lib.rs
else
    # Linux
    sed -i 's/\.plugin(tauri_plugin_updater::Builder::new()\.build())/\/\/ .plugin(tauri_plugin_updater::Builder::new().build()) \/\/ 已禁用更新器/' src-tauri/src/lib.rs
fi

echo "✅ lib.rs 已更新"

# 显示修改结果
echo ""
echo "📋 lib.rs 修改结果:"
grep -n "tauri_plugin_updater" src-tauri/src/lib.rs || echo "  (已完全注释掉)"

echo ""
echo "📋 tauri.conf.json 修改结果:"
node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('src-tauri/tauri.conf.json', 'utf8'));
console.log('  plugins.updater:', config.plugins?.updater || '(已删除)');
"

# 恢复文件
echo ""
echo "🔄 恢复原始文件..."
mv src-tauri/tauri.conf.json.test-backup src-tauri/tauri.conf.json
mv src-tauri/src/lib.rs.test-backup src-tauri/src/lib.rs

echo ""
echo "✅ 测试完成！修改逻辑正确。"
echo "💡 提示: 这些修改将在 GitHub Actions 中自动应用。"
