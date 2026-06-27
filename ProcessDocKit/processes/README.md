# فرایندها — ProcessDocKit

هر فرایند = یک **ProcessKey** (PascalCase انگلیسی = `wfClsName`).

```text
processes/{ProcessKey}/
├── input/
│   ├── meeting-minutes.md      ← صورتجلسه پرشده (از templates/user)
│   └── forms/                  ← فرم‌های کاغذی (PDF/Word/عکس)
├── output/                     ← Agent
│   ├── form-analysis-{Form}.md
│   └── process-charter.md
└── deliverables/
    └── {ProcessKey}-شناسنامه.docx
```

فهرست کل فرایندها: [`_INDEX.md`](./_INDEX.md)
