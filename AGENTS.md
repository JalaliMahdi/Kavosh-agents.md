# AGENTS.md — Bizagi BPM Runtime (Agent Playbook)

قرارداد Agent برای **هر** پوشه runtime مستقرشده Bizagi. قابل کپی بین محیط‌ها.
نام پروژه، host و دیتابیس را hardcode نکن — در زمان اجرا از config کشف کن.

> راهنمای تیم (قالب پیام، شروع سریع): [TEAM-GUIDE.md](./TEAM-GUIDE.md)
> چارت سازمانی (مرجع نقش‌ها برای Performers): [ORG-CHART.md](./ORG-CHART.md)
> کیت مستندسازی فرایند (واحد جدا — **قبل** طراحی): [ProcessDocKit/](./ProcessDocKit/README.md)
> مستندات طراحی و پیاده‌سازی (**حین/بعد** طراحی): [Docs/](./Docs/README.md)

**مرجع رسمی:** [Bizagi Process Wizard — ۷ مرحله](https://help.bizagi.com/platform/en/process_wizard.htm)

---

## ۱. هدف

- هم‌راستا با Process Wizard Studio (build → publish → run)
- spec اول، پیاده‌سازی توسط کاربر در Studio، verify از DB/trace
- شفاف‌سازی توانایی‌ها و محدودیت‌های Agent

---

## ۲. توانایی‌ها و محدودیت‌ها

### می‌تواند

- spec کامل فرایند (۷ مرحله) در `Docs/processes/{ProcessKey}/SPEC.md` — **فقط طراحی؛ بدون وضعیت verify**
- گزارش verify در `Docs/processes/{ProcessKey}/STATUS.md` — **با هر بررسی به‌روز**
- فایل **`{ProcessKey}.bpmn`** (BPMN 2.0 XML) — پیش‌نمایش در [bpmn.io](https://demo.bpmn.io/)؛ کاربر در Modeler طراحی می‌کند
- `VERIFY.sql` و اجرای read-only روی DB
- expression، validation، شرط gateway
- عیب‌یابی trace و `WORKITEM`
- اسکریپت migration (§۱۲، فقط in-place)

### نمی‌تواند

- تولید فایل **`.bpm`** (فرمت اختصاصی Bizagi Modeler — فقط با Save در Modeler ساخته می‌شود)
- کلیک در Studio / Modeler
- Publish
- bootstrap فرایند greenfield فقط با SQL
- تأیید runtime بدون Publish کاربر
- ادعای دیدن canvas Modeler بدون export/screenshot

---

## ۳. کشف context پروژه (قدم اجباری اول)

| تنظیم | منبع | کلید |
|-------|------|------|
| نام پروژه | `WebApplication/web.config` | `appSettings/Project` |
| دیتابیس | `WebApplication/web.config` | `appSettings/DSNDB`, `PROVIDERTYPE` |
| Assembly | `WebApplication/web.config` | `appSettings/AssemblyName` |
| URL پایه | `SitesApplication/appsettings.json` | `BizagiProjectURL` |
| ریشه runtime | workspace root | پوشه‌ای با `WebApplication/`, `Scheduler/` |
| نسخه | `WebApplication/version.json.txt` | `build` |

```bash
sqlcmd -S "{ServerFromDSN}" -d "{CatalogFromDSN}" -E -Q "SELECT 1"
```

رمزهای `CRYPT.1:` را در چت یا commit تکرار نکن.

**URL:** `{BaseUrl}/{Project}/` · OData: `.../Rest/odata/` · Live Processes: `.../Api/LiveProcesses`

**چیدمان پوشه‌ها (runtime root):**

```
{RuntimeRoot}/
├── AGENTS.md
├── TEAM-GUIDE.md
├── ORG-CHART.md
│
├── ProcessDocKit/                          ← قبل طراحی (واحد مستندسازی، قابل حذف)
│   ├── templates/user|agent/
│   └── processes/{ProcessKey}/             ← ProcessKey = wfClsName (PascalCase)
│       ├── input/                          ← صورتجلسه + forms/
│       ├── output/                         ← تحلیل Agent
│       └── deliverables/                   ← {ProcessKey}-شناسنامه.docx  ← ورودی فاز A۰
│
├── Docs/                                   ← حین و بعد طراحی (واحد طراحی Bizagi)
│   └── processes/{ProcessKey}/             ← همان ProcessKey
│       ├── SPEC.md · STATUS.md · VERIFY.sql · {ProcessKey}.bpmn
│       └── (آینده) سند پیاده‌سازی
│
├── WebApplication/
├── Scheduler/
├── SitesApplication/
└── Trace/
```

**ProcessKey:** نام انگلیسی PascalCase یکسان در ProcessDocKit، Docs و `WFCLASS.wfClsName`. عنوان فارسی فقط داخل متن اسناد.

---

## ۴. معماری

```
Studio (.bpex)  →  Publish  →  Runtime (IIS)  →  SQL Server (runtime truth)
```

| لایه | محل | Agent |
|------|-----|-------|
| Studio | `.bpex` | spec می‌دهد |
| Runtime | `WebApplication/`, `Scheduler/`, `SitesApplication/` | config، trace |
| Database | `DSNDB` | **فقط خواندن**؛ هرگز greenfield در SQL |

پوشه runtime Studio نیست.

---

## ۵. فازهای workflow (چرخه‌ی عمر)

نقشه‌ی کلان کار. **فاز A۰ نقطه‌ی شروع است؛** جزئیات مراحل ۱–۷ Wizard در §۶.

| فاز | Wizard | Agent |
|-----|--------|-------|
| A۰ — دریافت شناسنامه | ورودی | `ProcessDocKit/processes/{ProcessKey}/deliverables/{ProcessKey}-شناسنامه.docx` (از [ProcessDocKit](./ProcessDocKit/README.md))؛ مبنای SPEC و BPMN |
| A — Spec | ۱–۶ | `Docs/processes/{ProcessKey}/SPEC.md` (از روی شناسنامه) |
| B — Build | ۱–۶ | پاسخ به سؤالات |
| C — Publish | ۷ | SQL/trace verify → به‌روز `STATUS.md` |
| D — Test | ۷ | test case + `WORKITEM` |
| E — In-place | ۱–۳+۷ | §۱۲ |

**ترتیب مراحل Wizard:** ۲ قبل از ۳ · ۱ قبل از ۵.

**خواندن شناسنامه (فاز A۰):** مسیر: `ProcessDocKit/processes/{ProcessKey}/deliverables/{ProcessKey}-شناسنامه.docx`. docx باینری → استخراج (zip → `word/document.xml`). `{ProcessKey}` باید با پوشه‌ی `Docs/processes/{ProcessKey}/` یکسان باشد.

---

## ۶. Process Wizard — هفت مرحله

جزئیات مراحل فاز A/B (§۵). **وظیفه Agent:** deliverable هر مرحله → کاربر در Studio → Publish → verify در DB.
وابستگی‌های کلیدی این بخش: قالب SPEC (§۸) و قواعد نام‌گذاری (§۹).

### مرحله ۱ — Model Process

| Agent | Studio | Verify |
|-------|--------|--------|
| `{ProcessKey}.bpmn` + جدول Task | پیش‌نمایش bpmn.io → طراحی دستی در Modeler | `WORKFLOW`, `TASK`, `TRANSITION` |
| Mermaid در SPEC (مرجع متنی) | — | — |
| قوانین gateway (روایی + expression در BPMN) | بازبینی/تنظیم XOR gateway | `TRANSITIONCONDITION` |
| display name فرایند | WFClass properties | `WFCLASS` |

**Deliverable اجباری مرحله ۱:** `Docs/processes/{ProcessKey}/{ProcessKey}.bpmn`

**قوانین BPMN:**

- BPMN 2.0 XML استاندارد OMG
- `id` هر activity = `tskName` (مثلاً `SubmitLeave`) — برای تطابق با SPEC و verify
- `name` = display name فارسی یا انگلیسی
- laneها = نقش‌ها (کارمند، مدیر، HR)
- شرط gateway در `sequenceFlow` + expression مرحله ۴ در Studio تکمیل شود

**روند مرحله ۱ (تأییدشده تیم):**

1. Agent → `{ProcessKey}.bpmn`
2. کاربر → باز کردن در [demo.bpmn.io](https://demo.bpmn.io/) (`Ctrl+O`)
3. کاربر → طراحی همان جریان در Bizagi Modeler (دستی)
4. کاربر → Save → `.bpm` · ادامه Wizard

Agent `.bpm` تولید نمی‌کند. `.bpmn` مرجع بصری است — نه فایل import اجباری.

**`idTaskType` (این runtime):** مقادیر واقعی را از §۱۵ بگیر — Start=`1` · Manual=`2` · XOR diverging=`16` · merge=`9` · **End=`17`**. لیست عمومی Bizagi (که End را `6` می‌گوید) برای verify این نسخه **معتبر نیست**.

از `Activity_1`, `Event_1` در spec/BPMN پرهیز کن.

**نام‌گذاری Task در Studio (اجباری — قبل از رفتن به مرحله ۲؛ قواعد کامل در §۹):**

هر shape در Modeler **دو نام** دارد؛ هر دو را از SPEC پر کن:

| فیلد Studio | ستون SPEC | قانون | مثال |
|-------------|-----------|-------|------|
| **Name** (شناسه فنی) | `tskName` | PascalCase انگلیسی، بدون فاصله | `SubmitLeave` |
| **Display name** | Display name | زبان کاربر نهایی | `ثبت درخواست مرخصی` |

- **همه** taskهای انسانی، gatewayها و eventهای شروع/پایان نام معنادار بگیرند — نه پیش‌فرض Bizagi.
- `tskName` در SPEC، `.bpmn` (`id`) و `TASK.tskName` در DB باید **یکسان** باشند.
- Gateway: `Gateway_Approved` نه `Gateway_1` · Start/End: در SPEC صریح نام بده (مثلاً `EndApproved`, `EndRejected`).
- بعد از rename → **Publish Process** → verify:

```sql
SELECT tskName, tskDisplayName, idTaskType
FROM TASK WHERE idWorkflow = @idWorkflow AND deleted = 0 ORDER BY idTask;
```

اگر `Activity_1` یا `Event_1` در خروجی بود → هنوز مرحله ۱ کامل نیست.

### مرحله ۲ — Model Data

| Agent | Studio | Verify |
|-------|--------|--------|
| entity + context entity | Create/link entity | `ENTITY`, `BAWFCLASS_ENTITY` |
| جدول attribute + **نوع Studio** | Add attributes | `ATTRIB` |
| relations | Model relationships | collections / related entities |

**ستون «نوع Studio» در SPEC** (نه Date/Text عمومی): Date-time · String · Boolean (yes-no) · Integer · Extended Text · …

```sql
SELECT idAttrib, attribName, attribDisplayName, attribType, dataType
FROM ATTRIB
WHERE idEnt = (SELECT idEnt FROM ENTITY WHERE entName = @EntityName);
```

### مرحله ۳ — Define Forms

| Agent | Studio | Verify |
|-------|--------|--------|
| wireframe + xpath table | Edit form per task | رندر در Work Portal |
| editable/read-only | expressions | pre-fill صحیح |

فرم‌ها به مرحله ۲ وابسته‌اند. تغییر فرم → bump `formsVersion` → Publish.

### مرحله ۴ — Business Rules

| Agent | Studio | Verify |
|-------|--------|--------|
| شرط transition + expression | gateway conditions | `TRANSITIONCONDITION` |
| validation/default | form/entity rules | runtime behavior |

XPath کامل: `{ContextEntity}.field` — نه `field` تنها. `guidRule` را در Studio ویرایش کن، نه SQL.

### مرحله ۵ — Performers

| Agent | Studio | Verify |
|-------|--------|--------|
| ماتریس نقش/task | performer per activity | inbox صحیح |

نقش را حدس نزن — اول [ORG-CHART.md](./ORG-CHART.md)، سپس org publish state یا سؤال از کاربر.

### مرحله ۶ — Integrate

connector/REST/SAP/email — یا N/A. Verify: trace، `SOA/`.

### مرحله ۷ — Execute

چک‌لیست Publish + test case. Verify:

```sql
SELECT idWFClass, wfClsName, wfClsDisplayName FROM WFCLASS WHERE deleted = 0;
SELECT idTask, tskName, tskDisplayName, idTaskType FROM TASK WHERE idWorkflow = @idWorkflow;
SELECT idTransition, idTaskFrom, idTaskTo FROM TRANSITION WHERE idWorkflow = @idWorkflow;
SELECT wi.idWorkItem, t.tskName, wi.wiEntryDate, wi.wiSolutionDate
FROM WORKITEM wi JOIN TASK t ON wi.idTask = t.idTask
WHERE wi.idCase = @idCase ORDER BY wi.idWorkItem;
```

`wfDocument`/`wfXPDL` ممکن است NULL باشد؛ ساختار در `TASK`/`TRANSITION` کافی است.

---

## ۷. قوانین طلایی

**DO:** wizard صریح · کشف config · Publish = gate · SQL read-only · نام معنادار · بدون secret

**DON'T:** hardcode محیط · bootstrap greenfield در SQL · OData بدون auth · commit credential · ادعای diagram بدون screenshot

---

## ۸. قالب SPEC.md

```markdown
# Process: {ProcessDisplayName}
- WFClass: {ProcessKey}
- Context entity: {EntityName}
- Wizard steps: [1][2][3][4][5][6][7]

## Step 1 — Model Process
(فایل: {ProcessKey}.bpmn)
## Step 2 — Model Data
## Step 3 — Define Forms
## Step 4 — Business Rules
## Step 5 — Performers
## Step 6 — Integrate
## Step 7 — Execute
```

`VERIFY.sql` + `STATUS.md` در `Docs/processes/{ProcessKey}/`.

**قانون فایل‌ها (`Docs/processes/{ProcessKey}/`):**

| فایل | محتوا | Agent ویرایش می‌کند وقتی… |
|------|--------|---------------------------|
| `SPEC.md` | طراحی ثابت (۷ مرحله) | **اشتباه در spec** — اصلاح طراحی |
| `STATUS.md` | پیشرفت Wizard + نتیجه DB | **هر verify** بعد از Publish |
| `VERIFY.sql` | کوئری‌های read-only | اولین spec یا تغییر ساختار فرایند |
| `{ProcessKey}.bpmn` | دیاگرام مرجع | اولین spec یا تغییر جریان |
| *(آینده)* سند پیاده‌سازی | مستند پیاده‌سازی پس از طراحی | وقتی قالب تحویل داده شد |

**هرگز** وضعیت verify، پیشرفت Wizard یا نتیجه DB را در `SPEC.md` ننویس.

**تفکیک با ProcessDocKit:** شناسنامه و صورتجلسه در `ProcessDocKit/processes/{ProcessKey}/` می‌مانند — در Docs کپی/جابجا نکن مگر کاربر بخواهد.

---

## ۹. نام‌گذاری

| شیء | فیلد | قانون | بد | خوب |
|-----|------|-------|-----|------|
| WFClass | `wfClsName` | PascalCase انگلیسی | Process1 | LeaveRequest |
| Task | `tskName` | فعل + زمینه | Activity_1 | SubmitLeave |
| Task | `tskDisplayName` | زبان کاربر | Task 1 | ثبت درخواست مرخصی |
| Gateway | `tskName` | `Gateway_` + موضوع | Gateway_1 | Gateway_Approved |
| Event (End) | `tskName` | `End` + موضوع | Event_2 | EndRejected |
| Attribute | `attribName` | camelCase | f1 | requestReason |
| Entity | `entName` | نام دامنه | Process1 | LeaveRequest |

**SPEC.md** برای هر task هر دو ستون `tskName` و Display name را دارد — کاربر هر دو را در Studio تنظیم می‌کند.

---

## ۱۰. OData / Trace

- Metadata: `WebApplication/Rest/oData/Metadata/*.json`
- بدون session → SQL + trace ترجیح دارد
- Trace: `Trace/Diagnostics/*.log` — فیلتر `/{Project}/`

---

## ۱۱. مرجع DB

| حوزه | جداول |
|------|--------|
| فرایند | `WFCLASS`, `WORKFLOW`, `TASK`, `TRANSITION`, `TRANSITIONCONDITION` |
| data model | `ENTITY`, `ATTRIB`, `BAWFCLASS_ENTITY`, `ENTITYKEY` |
| catalog | `BABIZAGICATALOG` |
| cache | `BARENDERCACHE`, `BARENDERDATA` |
| runtime | `WFCASE`, `WORKITEM` |

Transition types: 1 Normal · 2 Exception · 4 Cancel · 5 Error

---

## ۱۲. In-place conversion (SQL + catalog)

فقط reshape فرایند **publish‌شده** — نه greenfield. ترجیح: Studio → Publish.

| موقعیت | §۱۲ | Studio |
|--------|-----|--------|
| rename / یک manual task / جریان خطی | بله | بله (ایمن‌تر) |
| attribute اسکالر + فرم | بله | بله |
| فرایند/entity/collection جدید | خیر | بله |

```
کشف → Plan → Snapshot (form JSON) → TASK/TRANSITION
  → BABIZAGICATALOG → ATTRIB/ENTITYKEY → clear cache → Verify
```

**objType:** 52 form · 125 activity · 487 attribute · 491 scope

**XPath:** `baxpath.xpath` = `{scopePrefix}.{suffix}` · suffix از `ENTITYKEY.guidEntityKey` (32 hex، no dash) — **نه** `guidAttrib`

**پس از تغییر:**

```sql
DELETE FROM BARENDERCACHE;
DELETE FROM BARENDERDATA;
```

کاربر: Recycle IIS · case جدید · backup DB قبل از Studio Publish

**Studio vs Runtime:** Publish = Studio→DB→web · §۱۲ = DB→web فقط · `AllowRemoteSynchronization=false` → sync معکوس خودکار نیست

---

## ۱۳. Runtime quirks

- `BizAgi.Generated.dll` missing → publish ناقص
- `DataCachePolicy.Get` NRE → cache warm-up
- `wfDocument` NULL → ساختار هنوز در `TASK`/`TRANSITION`

---

## ۱۴. چک‌لیست قبل از اتمام

- [ ] wizard steps و ترتیب ۱→۷
- [ ] کاربر Publish کرده
- [ ] SQL verify اجرا شد
- [ ] همه `TASK.tskName` معنادار (بدون `Activity_1`/`Gateway_1`) · `tskDisplayName` پر شده
- [ ] xpath کامل · test case مستند
- [ ] بدون secret
- [ ] §۱۲: ENTITYKEY · scope از export · recycle IIS

---

## ۱۵. Discoveries

- **۱۴۰۵/۰۳/۳۰:** `position` در بیزاجی **کلمه کلیدی رزروشده** است و نمی‌توان attribute با این نام ساخت. در SPEC از نام‌های جایگزین مثل `positions`, `jobPosition` یا `personnelPosition` استفاده کن. (به‌طور کلی نام‌های عمومی پرریسک: از پیشوند دامنه استفاده کن.)
- **۱۴۰۵/۰۳/۳۰ (Test30, build 11.2.5.1148):** مقادیر واقعی `TASK.idTaskType` در runtime این نسخه: Start=`1` · Manual=`2` · Gateway واگرا (XOR diverging)=`16` · Gateway همگرا (merge)=`9` · **End=`17`** (نه `6`). هنگام verify مرحله ۱ این مقادیر را معیار بگیر، نه لیست عمومی Bizagi.
- **۱۴۰۵/۰۳/۳۰:** **رویداد مرزی (Boundary interrupting event)** به‌صورت ردیف `TASK` مستقل ذخیره **نمی‌شود**؛ بیزاجی آن را به‌شکل یک `TRANSITION` با `idTransitionType=9` از task مبدأ به مقصد رویداد نگه می‌دارد. پس اگر تعداد TASK یکی کمتر از تعداد shapeهای BPMN بود (به‌ازای هر boundary event)، طبیعی است و نقص محسوب نمی‌شود.
- **۱۴۰۴/۰۳/۱۵:** Studio 11.x — انواع رایج: Date-time (نه Date)، String (نه Text)، Boolean (yes-no). در SPEC ستون «نوع Studio» بنویس.
- **۱۴۰۴/۰۳/۰۱:** xpath suffix = `ENTITYKEY` نه `guidAttrib` · catalog 487: `mtdState=0`, `contentFormat=0`
- **۱۴۰۴/۰۳/۰۱:** §۱۲ → Work Portal از DB · Studio از `.bpex` · Publish کهنه → revert runtime

---

*مستقل از محیط — یافته‌های جدید زیر Discoveries.*
