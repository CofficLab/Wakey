#!/usr/bin/env python3
"""校验 App Store 元数据文件的硬性限制。

App Store Connect 的 keywords 字段上限是 100 个字符，且用逗号分隔、
逗号后不能带空格（空格也会计入长度）。历史上英文关键词文件写了 206 个
字符，直接粘不进去。
"""

import pathlib
import sys

ROOT = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent
KEYWORD_FILES = ["keywords-en.txt", "keywords-zh.txt"]


def main():
    errors = []
    for name in KEYWORD_FILES:
        path = ROOT / "docs" / "metadata" / name
        text = path.read_text(encoding="utf-8").strip()
        if len(text) > 100:
            errors.append(f"{name}: {len(text)} 个字符，超过 100 上限")
        if not text:
            errors.append(f"{name}: 为空")
        if "，" in text:
            errors.append(f"{name}: 使用了全角逗号")
        if ", " in text:
            errors.append(f"{name}: 逗号后带空格，会额外占用字符")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("App Store 元数据校验通过")
    return 0


if __name__ == "__main__":
    sys.exit(main())
