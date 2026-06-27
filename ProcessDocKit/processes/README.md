# فرایندها — ProcessDocKit

هر فرایند = **ProcessKey** (PascalCase = `wfClsName`).

```text
processes/{ProcessKey}/
├── STATUS.md                         ← Gate فاز A0 (اجباری)
├── input/
│   ├── meeting-minutes.md
│   ├── *.docx                        ← صورتجلسه خام (اختیاری)
│   └── forms/
├── output/
│   ├── form-analysis-*.md
│   ├── process-charter.md
│   └── charter-gate-checklist.md     ← Gate
└── deliverables/
    └── {ProcessKey}-شناسنامه.docx    ← Word سازمان
```

- فهرست: [`_INDEX.md`](./_INDEX.md)
- راهنما: [`../CHARTER-GUIDE.md`](../CHARTER-GUIDE.md)
- اعتبارسنجی: `python ProcessDocKit/tools/validate-charter.py {ProcessKey}`

**Gate = آماده برای Docs** → `Docs/processes/{ProcessKey}/SPEC.md`
