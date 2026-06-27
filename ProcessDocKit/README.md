# ProcessDocKit — مستندسازی **قبل** طراحی فرایند

این کیت متعلق به **واحد مستندسازی** است (قابل جداسازی از پروژه).  
خروجی آن **شناسنامه فرایند** است — مبنای شروع طراحی در Bizagi (فاز A۰ در `AGENTS.md`).

> طراحی، verify و مستند پیاده‌سازی → در [`Docs/`](../Docs/README.md) (بعد از تحویل شناسنامه).

---

## چرخه در یک پروژه با چند فرایند

```text
                    ProcessDocKit                    Docs
                 (قبل طراحی)              (حین و بعد طراحی + پیاده‌سازی)
                        │                              │
  جلسه + فرم ──► input/ ──► output/ ──► deliverables/ ──► SPEC · BPMN · STATUS · VERIFY · …
                        │         شناسنامه.docx              (همان ProcessKey)
                        └──────────────── ProcessKey ────────┘
```

**ProcessKey** = نام انگلیسی PascalCase = `wfClsName` در Bizagi (مثلاً `WarehouseRequest`).  
عنوان فارسی فقط داخل متن اسناد — **نه** نام پوشه.

---

## ساختار

```text
ProcessDocKit/
├── README.md
├── templates/                    ← مشترک (یک‌بار)
│   ├── user/                     ← تو پر می‌کنی
│   └── agent/                    ← Agent پر می‌کند
├── processes/                    ← یک پوشه به ازای هر فرایند
│   ├── _INDEX.md                 ← فهرست و وضعیت همه فرایندها
│   ├── README.md
│   └── {ProcessKey}/
│       ├── input/                ← تو: صورتجلسه + forms/
│       ├── output/               ← Agent: تحلیل + شناسنامه.md
│       └── deliverables/         ← شناسنامه Word نهایی
├── word/                         ← قالب‌های خالی Word (اختیاری)
└── tools/md2docx.py
```

---

## شروع فرایند جدید

```powershell
$Key = "WarehouseRequest"   # = wfClsName

mkdir ProcessDocKit\processes\$Key\input\forms
mkdir ProcessDocKit\processes\$Key\output
mkdir ProcessDocKit\processes\$Key\deliverables

copy ProcessDocKit\templates\user\01-meeting-minutes.md `
     ProcessDocKit\processes\$Key\input\meeting-minutes.md
```

بعد از جلسه: فرم‌ها → `input/forms/` · ردیف جدید در `processes/_INDEX.md`.

---

## Agent مستندسازی

1. `processes/{ProcessKey}/input/` را بخوان.
2. `output/form-analysis-*.md` + `output/process-charter.md` تولید کن.
3. Word → `deliverables/{ProcessKey}-شناسنامه.docx`
4. `_INDEX.md` را به‌روز کن (وضعیت: شناسنامه تحویل شد).

---

## تبدیل Word

```powershell
python ProcessDocKit/tools/md2docx.py --templates

python ProcessDocKit/tools/md2docx.py `
  ProcessDocKit/processes/WarehouseRequest/output/process-charter.md `
  ProcessDocKit/processes/WarehouseRequest/deliverables/WarehouseRequest-شناسنامه.docx
```

---

## اتصال به Docs (طراحی Bizagi)

| | ProcessDocKit | Docs |
|---|---------------|------|
| **زمان** | قبل طراحی | حین و بعد طراحی |
| **مسیر** | `processes/{ProcessKey}/` | `Docs/processes/{ProcessKey}/` |
| **ProcessKey** | یکسان | یکسان |
| **خروجی کلیدی** | `deliverables/*-شناسنامه.docx` | `SPEC.md` · `.bpmn` · `STATUS.md` · … |

واحد طراحی شناسنامه را از `ProcessDocKit/processes/{ProcessKey}/deliverables/` می‌خواند و artefactهای طراحی را در `Docs/processes/{ProcessKey}/` می‌سازد.
