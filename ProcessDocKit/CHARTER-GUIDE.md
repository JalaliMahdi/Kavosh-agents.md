# CHARTER-GUIDE — فاز A0: شناسنامه فرایند (قبل از Bizagi)

راهنمای **تمیز و بی‌نقص** بودن مستندسازی قبل از طراحی.  
مکمل [README.md](./README.md) · مرجع Agent در [AGENTS.md](../AGENTS.md) §۵ فاز A0.

---

## ۱. هدف فاز A0

| | |
|---|---|
| **ورودی** | صورتجلسه + فرم(های) کاغذی (+ قالب Word سازمان در صورت وجود) |
| **خروجی تحویل** | `deliverables/{ProcessKey}-شناسنامه.docx` (قالب رسمی سازمان) |
| **خروجی Agent** | `output/process-charter.md` + `form-analysis-*.md` + `charter-gate-checklist.md` |
| **Gate** | `STATUS.md` → **آماده برای Docs** — سپس فاز A (`SPEC.md`) |

**قانون:** تا Gate سبز نشود، `Docs/processes/{ProcessKey}/` شروع **نشود**.

---

## ۲. نقش‌ها

| نقش | کار |
|-----|-----|
| **تحلیلگر / کاربر** | جلسه، `input/` (صورتجلسه، فرم‌ها)، تأیید نهایی Gate |
| **Agent** | ساختاردهی، تحلیل فرم، `process-charter.md`، چک‌لیست Gate، `STATUS.md` |
| **مالک فرایند** | تأیید Word نهایی (امضا در قالب سازمان) |

---

## ۳. artefactهای اجباری (هر ProcessKey)

```text
processes/{ProcessKey}/
├── STATUS.md                         ← وضعیت فاز A0 (Agent به‌روز)
├── input/
│   ├── meeting-minutes.md            ← ساختاریافته (Template 1)
│   ├── صورتجلسه.docx                 ← منبع خام (در صورت Word)
│   └── forms/                        ← هر فرم کاغذی
├── output/
│   ├── process-charter.md            ← مرجع Agent (Template 3)
│   ├── form-analysis-{Form}.md       ← به ازای هر فرم (Template 2)
│   └── charter-gate-checklist.md     ← Gate (Template 4)
└── deliverables/
    └── {ProcessKey}-شناسنامه.docx    ← تحویل رسمی
```

---

## ۴. Word: قالب سازمان vs md2docx

| روش | کاربرد | تحویل رسمی؟ |
|-----|--------|-------------|
| **قالب Word سازمان** | `word/شناسنامه-فرایند-قالب.docx` یا فایل پرشده سازمان | **بله** → `deliverables/` |
| **md2docx** | پیش‌نمایش Markdown، قالب‌های خالی Template | **خیر** — فقط کمکی |

**روند صحیح:**

1. اگر سازمان قالب/شناسنامه Word دارد → کپی/به‌روز در `deliverables/{ProcessKey}-شناسنامه.docx`.
2. Agent محتوای Word را در `process-charter.md` منعکس کند (یکسان‌سازی کد فرایند، KPI، سیستم‌ها).
3. `md2docx` **جایگزین** قالب سازمان **نیست**.

---

## ۵. گام‌های Agent (ترتیب)

```text
[1] input/ بخوان (صورتجلسه + forms/)
[2] meeting-minutes.md ساخت/به‌روز (Template 1)
[3] form-analysis-*.md به ازای هر فرم (Template 2)
[4] process-charter.md (Template 3) — هم‌راستا با Word سازمان
[5] deliverables/*-شناسنامه.docx = قالب Word رسمی
[6] charter-gate-checklist.md (Template 4) — همه بندها
[7] STATUS.md → Gate
[8] processes/_INDEX.md
[9] python tools/validate-charter.py {ProcessKey}
```

---

## ۶. Gate — شرط «آماده برای Docs»

همه بندهای **الزami** در `charter-gate-checklist.md` باید ✅ یا 🟡 (باز + پیش‌فرض طراحی ثبت‌شده) باشند.

| بند | معیار |
|-----|--------|
| G1 | `input/` صورتجلسه + حداقل یک منبع فرایند |
| G2 | `meeting-minutes.md` بخش‌های ۳–۸ پر |
| G3 | هر فرم در `forms/` → `form-analysis-*.md` |
| G4 | `process-charter.md` کامل (§۱–۲۱) |
| G5 | `deliverables/*-شناسنامه.docx` = قالب سازمان (>۱۰۰KB معمولاً) |
| G6 | مغایرت‌ها در § ابهامات + پیش‌فرض طراحی |
| G7 | ProcessKey = wfClsName پیشنهادی ثبت شده |
| G8 | `validate-charter.py` بدون خطا |

**🟡 مجاز:** metadata جلسه، امضای فیزیکی، فیلدهای «بعداً در Studio» — با پیش‌فرض Agent.

**🔴 توقف Gate:** بدون شرح فرایند، بدون Word تحویل، بدون ProcessKey.

---

## ۷. شروع فرایند جدید

```powershell
$Key = "MyProcess"   # PascalCase = wfClsName

$base = "ProcessDocKit\processes\$Key"
mkdir "$base\input\forms", "$base\output", "$base\deliverables"

copy ProcessDocKit\templates\user\01-meeting-minutes.md "$base\input\meeting-minutes.md"
copy ProcessDocKit\templates\agent\04-charter-gate-checklist.md "$base\output\charter-gate-checklist.md"

# STATUS از قالب:
copy ProcessDocKit\templates\agent\05-charter-status.md "$base\STATUS.md"
# سپس {ProcessKey} را در STATUS جایگزین کن
```

ردیف در `processes/_INDEX.md` · بعد از جلسه فرم‌ها → `input/forms/`.

---

## ۸. اعتبارسنجی

```powershell
python ProcessDocKit/tools/validate-charter.py WarehouseRequest
python ProcessDocKit/tools/validate-charter.py --all
```

---

## ۹. اتصال به Docs

وقتی `STATUS.md` = **آماده برای Docs**:

1. Agent می‌خواند: `deliverables/*-شناسنامه.docx` + `output/process-charter.md`
2. می‌سازد: `Docs/processes/{ProcessKey}/SPEC.md` (+ `.bpmn` مرحله ۱)
3. `ProcessDocKit` دست نخورده می‌ماند (source of truth فاز A0)

---

## ۱۰. خطاهای رایج

| خطا | اصلاح |
|-----|--------|
| فقط md2docx در deliverables | قالب Word سازمان جایگزین کن |
| فرم بدون form-analysis | Template 2 برای هر فرم |
| SPEC قبل از Gate | اول `validate-charter.py` |
| ProcessKey متفاوت در پوشه‌ها | یک نام PascalCase همه‌جا |
