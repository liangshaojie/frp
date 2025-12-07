#!/usr/bin/env node
/**
 * 清理 Markdown-PDF 生成的 HTML，使其适合 WordPress
 * 使用方法：node clean-html-for-wordpress.js 内网穿透.html
 */

const fs = require('fs');
const path = require('path');

// 获取输入文件
const inputFile = process.argv[2];
if (!inputFile) {
  console.error('❌ 请提供 HTML 文件路径');
  console.log('使用方法: node clean-html-for-wordpress.js 内网穿透.html');
  process.exit(1);
}

// 读取 HTML 文件
let html = fs.readFileSync(inputFile, 'utf-8');

console.log('🔧 开始清理 HTML...');

// 0. 提取 body 标签内的内容
const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/);
if (bodyMatch) {
    html = bodyMatch[1];
    console.log('✓ 已提取 body 内容');
}

// 1. 移除所有 hljs 相关的 span 标签，但保留内容
html = html.replace(/<span class="hljs-[^"]*">([^<]*)<\/span>/g, '$1');

// 2. 移除多余的 div 和 span 包装
html = html.replace(/<div><span class="[^"]*">([^<]*)<\/span>/g, '<div>$1');

// 3. 清理代码块中的多余标签
for (let i = 0; i < 5; i++) {
    html = html.replace(/<span[^>]*>([^<]*)<\/span>/g, '$1');
}

// 4. 移除代码块外层和内层的 div 标签
html = html.replace(/<div>\s*<pre>/g, '<pre>');
html = html.replace(/<\/pre>\s*<\/div>/g, '</pre>');
// 移除 <code> 标签内的 <div>
html = html.replace(/<code><div>/g, '<code>');
html = html.replace(/<\/div><\/code>/g, '</code>');

// 5. 移除空的 span 标签
html = html.replace(/<span[^>]*>\s*<\/span>/g, '');
html = html.replace(/<div[^>]*>\s*<\/div>/g, '');

// 6. 简化代码块结构
html = html.replace(/<pre><code class="language-(\w+)">/g, '<pre><code class="language-$1">');

// 7. 清理多余的空白行
html = html.replace(/\n\s*\n\s*\n/g, '\n\n');

// 8. 为 WordPress 优化表格
html = html.replace(/<table>/g, '<table class="wp-block-table">');

// 9. 优化图片标签
html = html.replace(/<img([^>]*)>/g, '<img$1 class="wp-image">');

// 10. 移除最外层的 div（如果存在）
html = html.trim();
if (html.startsWith('<div>') && html.endsWith('</div>')) {
    const temp = html.substring(5, html.length - 6).trim();
    if (!temp.startsWith('<div>')) {
        html = temp;
        console.log('✓ 已移除最外层 div');
    }
}

// 生成输出文件
const outputFile = inputFile.replace('.html', '-wordpress.html');
fs.writeFileSync(outputFile, html, 'utf-8');

console.log('✅ 清理完成！');
console.log(`📄 输出文件: ${outputFile}`);
console.log('\n💡 提示：');
console.log('1. 在 WordPress 中切换到"代码编辑器"模式');
console.log('2. 粘贴清理后的 HTML 内容');
console.log('3. 切换回"可视化编辑器"查看效果');
