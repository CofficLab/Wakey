#!/usr/bin/env python3
"""向 .xcstrings 追加文案，保持 Xcode 的 2 空格缩进格式。

用法:
    python3 scripts/add_xcstrings_entries.py <file.xcstrings> <json-payload>

payload 格式:
    {
      "strings": {
        "<key>": {"zh-Hans": "...", "zh-HK": "...", "comment": "..."}
      }
    }
"""
import json
import sys
from collections import OrderedDict


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2

    path, payload_path = sys.argv[1], sys.argv[2]
    with open(path, encoding="utf-8") as handle:
        catalog = json.load(handle, object_pairs_hook=OrderedDict)
    with open(payload_path, encoding="utf-8") as handle:
        payload = json.load(handle, object_pairs_hook=OrderedDict)

    strings = catalog["strings"]
    added = 0
    for key, entry in payload["strings"].items():
        if key in strings:
            continue
        item = OrderedDict()
        if entry.get("comment"):
            item["comment"] = entry["comment"]
        localizations = OrderedDict()
        for locale in ("zh-Hans", "zh-HK"):
            if locale not in entry:
                continue
            localizations[locale] = OrderedDict([
                ("stringUnit", OrderedDict([
                    ("state", "translated"),
                    ("value", entry[locale]),
                ])),
            ])
        item["localizations"] = localizations
        strings[key] = item
        added += 1

    # 保持 key 的字典序（Xcode 写出顺序）
    catalog["strings"] = OrderedDict(sorted(strings.items(), key=lambda kv: kv[0]))

    with open(path, "w", encoding="utf-8") as handle:
        json.dump(catalog, handle, ensure_ascii=False, indent=2)
        handle.write("\n")

    print(f"added {added} entries to {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
