#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""validate-charter — Gate فاز A0: بررسی artefactهای شناسنامه قبل از Docs."""
import os
import sys
import glob

KIT = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
PROCESSES = os.path.join(KIT, "processes")
MIN_WORD_BYTES = 50_000  # قالب سازمان معمولاً >> md2docx


def check_process(key: str) -> list[str]:
    base = os.path.join(PROCESSES, key)
    errors: list[str] = []
    warnings: list[str] = []

    if not os.path.isdir(base):
        return [f"پوشه processes/{key}/ وجود ندارد"]

    def req(path: str, label: str, warn_only: bool = False):
        full = os.path.join(base, path)
        if not os.path.exists(full):
            (warnings if warn_only else errors).append(f"ندارد: {path} ({label})")

    req("input/meeting-minutes.md", "صورتجلسه ساختاریافته")
    has_docx = glob.glob(os.path.join(base, "input", "*.docx"))
    if not has_docx:
        warnings.append("input/*.docx (صورتجلسه خام) — اختیاری اگر meeting-minutes کامل است")

    req("output/process-charter.md", "شناسنامه Agent")
    req("output/charter-gate-checklist.md", "Gate checklist")
    req("STATUS.md", "STATUS فاز A0")

    forms_dir = os.path.join(base, "input", "forms")
    if os.path.isdir(forms_dir):
        forms = [f for f in os.listdir(forms_dir) if not f.startswith("_") and f.lower().endswith((".docx", ".pdf", ".png", ".jpg"))]
        analyses = glob.glob(os.path.join(base, "output", "form-analysis-*.md"))
        if forms and len(analyses) < len(forms):
            errors.append(f"form-analysis: {len(analyses)} فایل برای {len(forms)} فرم در forms/")

    deliverables = glob.glob(os.path.join(base, "deliverables", f"{key}-*.docx"))
    if not deliverables:
        errors.append(f"deliverables/{key}-شناسنامه.docx موجود نیست")
    else:
        size = os.path.getsize(deliverables[0])
        if size < MIN_WORD_BYTES:
            warnings.append(
                f"deliverables حجم {size}B — احتمالاً md2docx است نه قالب سازمان (>{MIN_WORD_BYTES}B)"
            )

    charter = os.path.join(base, "output", "process-charter.md")
    if os.path.isfile(charter):
        text = open(charter, encoding="utf-8").read()
        if "ProcessKey" not in text and key not in text:
            warnings.append("process-charter.md ProcessKey را ذکر نکرده")
        if "ابهامات" not in text:
            errors.append("process-charter.md § ابهامات ندارد")

    index_path = os.path.join(PROCESSES, "_INDEX.md")
    if os.path.isfile(index_path):
        idx = open(index_path, encoding="utf-8").read()
        if key not in idx:
            warnings.append(f"{key} در processes/_INDEX.md نیست")

    return errors + [f"⚠ {w}" for w in warnings]


def main():
    args = sys.argv[1:]
    if not args:
        print("Usage: validate-charter.py <ProcessKey> | --all")
        sys.exit(1)

    keys = []
    if args[0] == "--all":
        if not os.path.isdir(PROCESSES):
            sys.exit(0)
        keys = [
            d for d in os.listdir(PROCESSES)
            if os.path.isdir(os.path.join(PROCESSES, d)) and not d.startswith("_")
        ]
    else:
        keys = [args[0]]

    failed = False
    for key in keys:
        issues = check_process(key)
        if not issues:
            print(f"OK: {key}")
        else:
            hard = [i for i in issues if not i.startswith("⚠")]
            print(f"{'FAIL' if hard else 'WARN'}: {key}")
            for i in issues:
                print(f"  - {i}")
            if hard:
                failed = True

    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
