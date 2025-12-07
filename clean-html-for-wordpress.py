#!/usr/bin/env python3
"""
清理 Markdown-PDF 生成的 HTML，使其适合 WordPress
使用方法：python clean-html-for-wordpress.py 内网穿透.html
"""

import re
import sys
from pathlib import Path

def clean_html_for_wordpress(html_content):
    """清理 HTML 内容"""
    
    print("🔧 开始清理 HTML...")
    
    # 0. 提取 body 标签内的内容
    body_match = re.search(r'<body[^>]*>(.*?)</body>', html_content, re.DOTALL)
    if body_match:
        html_content = body_match.group(1)
        print("✓ 已提取 body 内容")
    
    # 1. 移除所有 hljs 相关的 span 标签，但保留内容
    html_content = re.sub(r'<span class="hljs-[^"]*">([^<]*)</span>', r'\1', html_content)
    
    # 2. 移除 hljs-section、hljs-attr 等包装
    html_content = re.sub(r'<span class="hljs-\w+">([^<]+)</span>', r'\1', html_content)
    
    # 3. 清理嵌套的 span 标签
    for _ in range(5):  # 多次清理以处理嵌套
        html_content = re.sub(r'<span[^>]*>([^<]*)</span>', r'\1', html_content)
    
    # 4. 移除代码块外层和内层的 div 标签
    html_content = re.sub(r'<div>\s*<pre>', r'<pre>', html_content)
    html_content = re.sub(r'</pre>\s*</div>', r'</pre>', html_content)
    # 移除 <code> 标签内的 <div>
    html_content = re.sub(r'<code><div>', r'<code>', html_content)
    html_content = re.sub(r'</div></code>', r'</code>', html_content)
    
    # 5. 移除空的标签
    html_content = re.sub(r'<span[^>]*>\s*</span>', '', html_content)
    html_content = re.sub(r'<div[^>]*>\s*</div>', '', html_content)
    
    # 6. 清理代码块中的注释标签
    html_content = re.sub(r'<span class="hljs-comment">#([^<]*)</span>', r'#\1', html_content)
    
    # 7. 简化 pre/code 结构
    html_content = re.sub(
        r'<pre><code class="language-(\w+)">',
        r'<pre><code class="language-\1">',
        html_content
    )
    
    # 8. 清理多余的空白行
    html_content = re.sub(r'\n\s*\n\s*\n', '\n\n', html_content)
    
    # 9. 移除内联样式（可选，取消注释以启用）
    # html_content = re.sub(r'\s*style="[^"]*"', '', html_content)
    
    # 10. 为 WordPress 优化表格
    html_content = re.sub(r'<table>', r'<table class="wp-block-table">', html_content)
    
    # 11. 优化图片标签
    html_content = re.sub(
        r'<img([^>]*)>',
        r'<img\1 class="wp-image">',
        html_content
    )
    
    # 12. 移除最外层的 div（如果存在）
    html_content = html_content.strip()
    if html_content.startswith('<div>') and html_content.endswith('</div>'):
        # 检查是否是包裹整个内容的单个 div
        temp = html_content[5:-6].strip()  # 移除 <div> 和 </div>
        if not temp.startswith('<div>'):  # 确保不是误删内容 div
            html_content = temp
            print("✓ 已移除最外层 div")
    
    print("✅ 清理完成！")
    return html_content

def main():
    # 检查参数
    if len(sys.argv) < 2:
        print("❌ 请提供 HTML 文件路径")
        print("使用方法: python clean-html-for-wordpress.py 内网穿透.html")
        sys.exit(1)
    
    # 读取输入文件
    input_file = Path(sys.argv[1])
    if not input_file.exists():
        print(f"❌ 文件不存在: {input_file}")
        sys.exit(1)
    
    print(f"📖 读取文件: {input_file}")
    html_content = input_file.read_text(encoding='utf-8')
    
    # 清理 HTML
    cleaned_html = clean_html_for_wordpress(html_content)
    
    # 保存输出文件
    output_file = input_file.with_stem(input_file.stem + '-wordpress')
    output_file.write_text(cleaned_html, encoding='utf-8')
    
    print(f"📄 输出文件: {output_file}")
    print("\n💡 使用提示：")
    print("1. 在 WordPress 编辑器中，点击右上角的三个点")
    print("2. 选择 '代码编辑器' 模式")
    print("3. 粘贴清理后的 HTML 内容")
    print("4. 切换回 '可视化编辑器' 查看效果")
    print("\n⚠️  注意事项：")
    print("- PlantUML 图表可能需要手动调整")
    print("- 建议使用 WordPress 的 Markdown 插件以获得更好的效果")

if __name__ == '__main__':
    main()
