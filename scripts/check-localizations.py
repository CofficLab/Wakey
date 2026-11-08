#!/usr/bin/env python3
"""校验所有 String Catalog 的繁体中文语言标签一致。

历史问题：繁体中文同时以 zh-HK / zh-Hant / zh-TW 三种标签分散在不同
catalog 里。zh-HK 与 zh-Hant 是不同语言标签，Apple 不会把它们互相回退，
所以同一份繁体文案只在 zh-HK 下有的条目，对 zh-Hant 用户会退回英文。

规范：每个条目只允许 en / zh-Hans / zh-Hant；有 zh-Hans 的条目必须有
zh-Hant，且不得残留 zh-HK 或 zh-TW。
"""

import json
import pathlib
import sys

ALLOWED = {"en", "zh-Hans", "zh-Hant"}
DEFAULT_ROOT = pathlib.Path(__file__).resolve().parent.parent
ROOT = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else DEFAULT_ROOT


def catalogs():
    for path in ROOT.rglob("*.xcstrings"):
        if ".build" in path.parts:
            continue
        yield path


def entries(node):
    if isinstance(node, dict):
        if isinstance(node.get("localizations"), dict):
            yield node["localizations"]
        for value in node.values():
            yield from entries(value)
    elif isinstance(node, list):
        for value in node:
            yield from entries(value)


def main():
    errors = []
    for path in catalogs():
        data = json.loads(path.read_text(encoding="utf-8"))
        for localizations in entries(data):
            tags = set(localizations)
            relative = path.relative_to(ROOT)
            if "zh-HK" in tags or "zh-TW" in tags:
                errors.append(f"{relative}: 残留 zh-HK/zh-TW 标签")
            if tags - ALLOWED:
                errors.append(f"{relative}: 未预期的语言标签 {sorted(tags - ALLOWED)}")
            if "zh-Hans" in tags and "zh-Hant" not in tags:
                errors.append(f"{relative}: 有 zh-Hans 但缺少 zh-Hant")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        print(f"{len(errors)} 处语言标签不一致")
        return 1
    print("所有 catalog 的繁体中文标签一致")
    return 0


if __name__ == "__main__":
    sys.exit(main())
