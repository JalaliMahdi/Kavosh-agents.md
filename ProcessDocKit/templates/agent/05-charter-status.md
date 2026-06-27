# STATUS — فاز A0 (شناسنامه): {ProcessKey}

> وضعیت **مستندسازی قبل از طراحی** — نه Wizard Bizagi.  
> Wizard → `Docs/processes/{ProcessKey}/STATUS.md`

---

## خلاصه

| قلم | مقدار |
|-----|-------|
| ProcessKey | {ProcessKey} |
| عنوان فارسی | |
| فاز | A0 — ProcessDocKit |
| Gate | ☐ در جریان · ☐ آماده برای Docs · ☐ تحویل شد |
| آخرین به‌روزرسانی | |

---

## artefactها

| artefact | مسیر | وضعیت |
|----------|------|--------|
| صورتجلسه | input/ | ☐ |
| meeting-minutes | input/meeting-minutes.md | ☐ |
| فرم(ها) | input/forms/ | ☐ |
| form-analysis | output/form-analysis-*.md | ☐ |
| process-charter | output/process-charter.md | ☐ |
| Gate checklist | output/charter-gate-checklist.md | ☐ |
| شناسنامه Word | deliverables/{ProcessKey}-شناسنامه.docx | ☐ |

---

## Gate

```powershell
python ProcessDocKit/tools/validate-charter.py {ProcessKey}
```

| اجرا | تاریخ | نتیجه |
|------|-------|--------|
| | | |

---

## یادداشت‌ها

- 

---

## پس از Gate

- [ ] شروع `Docs/processes/{ProcessKey}/SPEC.md`
- [ ] _INDEX.md ستون «طراحی Bizagi»
