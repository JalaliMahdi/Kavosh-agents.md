# ProcessDocKit — مستندسازی **قبل** طراحی فرایند

خروجی: **شناسنامه فرایند** (فاز A0) — Gate قبل از `Docs/` و Bizagi Studio.

> **راهنمای کامل فاز A0:** [CHARTER-GUIDE.md](./CHARTER-GUIDE.md)  
> طراحی Bizagi → [`Docs/`](../Docs/README.md)

---

## چرخه

```text
  جلسه + فرم ──► input/ ──► output/ ──► deliverables/ ──► [Gate] ──► Docs/SPEC
                      │         │              │
                      │         │         Word سازمان
                      └─────────┴── process-charter.md (Agent)
```

**ProcessKey** = PascalCase = `wfClsName` (مثلاً `WarehouseRequest`)

---

## ساختار

```text
ProcessDocKit/
├── README.md
├── CHARTER-GUIDE.md              ← Gate فاز A0 (اجباری Agent)
├── templates/
│   ├── user/01-meeting-minutes.md
│   └── agent/02-form-analysis.md · 03-process-charter.md
│       · 04-charter-gate-checklist.md · 05-charter-status.md
├── processes/{ProcessKey}/
│   ├── STATUS.md                 ← وضعیت Gate A0
│   ├── input/ · output/ · deliverables/
├── word/                         ← قالب Word سازمان
└── tools/
    ├── md2docx.py                ← پیش‌نمایش MD (نه تحویل رسمی)
    └── validate-charter.py       ← Gate checker
```

---

## شروع فرایند جدید

```powershell
$Key = "WarehouseRequest"

$base = "ProcessDocKit\processes\$Key"
mkdir "$base\input\forms", "$base\output", "$base\deliverables"

copy ProcessDocKit\templates\user\01-meeting-minutes.md "$base\input\meeting-minutes.md"
copy ProcessDocKit\templates\agent\04-charter-gate-checklist.md "$base\output\charter-gate-checklist.md"
copy ProcessDocKit\templates\agent\05-charter-status.md "$base\STATUS.md"
# جایگزین {ProcessKey} در STATUS.md
```

---

## Agent — ترتیب کار

1. `input/` بخوان
2. `output/form-analysis-*.md` + `process-charter.md`
3. **`deliverables/{ProcessKey}-شناسنامه.docx` = قالب Word سازمان** (نه فقط md2docx)
4. `charter-gate-checklist.md` + `STATUS.md` → Gate
5. `python ProcessDocKit/tools/validate-charter.py {ProcessKey}`
6. `_INDEX.md`

جزئیات: [CHARTER-GUIDE.md](./CHARTER-GUIDE.md)

---

## Word: تحویل رسمی

| | |
|---|---|
| **تحویل رسمی** | `deliverables/{ProcessKey}-شناسنامه.docx` از **قالب سازمان** |
| **md2docx** | فقط پیش‌نمایش Markdown — جایگزین قالب **نیست** |

```powershell
# پیش‌نمایش (اختیاری):
python ProcessDocKit/tools/md2docx.py processes/WarehouseRequest/output/process-charter.md /tmp/preview.docx

# Gate:
python ProcessDocKit/tools/validate-charter.py WarehouseRequest
```

---

## اتصال به Docs

| | ProcessDocKit | Docs |
|---|---------------|------|
| زمان | قبل طراحی (A0) | حین طراحی (A–C) |
| Gate | `STATUS.md` = آماده برای Docs | `SPEC.md` شروع |
| خروجی کلیدی | `deliverables/*-شناسنامه.docx` | `SPEC.md` · `.bpmn` · `STATUS.md` |

**تا Gate سبز نشود، SPEC نساز.**
