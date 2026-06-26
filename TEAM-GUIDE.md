# راهنمای تیم — هفت مرحله Wizard + Cursor

راهنمای اعضای تیم برای ساخت فرایند در **Bizagi Studio** با کمک **Agent (Cursor)**.

| سند | مخاطب | نقش |
|-----|--------|-----|
| **این فایل** | شما | چه کار کنید — گام‌به‌گام Wizard |
| **[AGENTS.md](./AGENTS.md)** | Agent | قرارداد فنی — نخوانید؛ فقط در چت ارجاع دهید |
| **`SPEC.md`** | شما + Agent | طراحی ثابت هر فرایند |
| **`STATUS.md`** | شما + Agent | پیشرفت + نتیجه verify |

**مرجع Bizagi:** [Process Wizard — ۷ مرحله](https://help.bizagi.com/platform/en/process_wizard.htm)

---

## قبل از Wizard — یک‌بار

### نقش‌ها

| نقش | کار |
|-----|-----|
| **Agent** | spec، `.bpmn`، expression، verify |
| **شما** | Studio + Publish |

### شروع در Cursor

1. پوشه runtime پروژه را باز کنید (`WebApplication/` دارد)
2. هر چت با این جمله شروع شود:

```
طبق AGENTS.md عمل کن
```

### درخواست فرایند جدید از Agent

```
طبق AGENTS.md عمل کن.
می‌خوام فرایند «[نام فارسی]» را طراحی کنی.
توضیح: [چه کاری انجام می‌دهد]
شرکت‌کنندگان: [چه کسانی task دارند]
شرط‌ها: [قوانین کسب‌وکار]
```

Agent می‌سازد:

```
docs/processes/{ProcessName}/
├── SPEC.md           ← طراحی (ثابت)
├── STATUS.md         ← پیشرفت + verify
├── {ProcessName}.bpmn
└── VERIFY.sql
```

### پیام verify (بعد از هر مرحله)

```
طبق AGENTS.md عمل کن.
فرایند [ProcessName] — مرحله [N] تمام شد. VERIFY کن.
```

### قالب‌های پیام دیگر

**Expression:**
```
طبق AGENTS.md عمل کن.
expression بنویس: [توضیح] · context entity: [EntityName]
```

**عیب‌یابی:**
```
طبق AGENTS.md عمل کن.
case [idCase] در task [TaskName] گیر کرده.
```

---

## نقشه کلی Wizard

```
مرحله ۱ Model Process     → Publish Process      → VERIFY
مرحله ۲ Model Data        → Publish Entity       → VERIFY
مرحله ۳ Define Forms      → Publish Process      → VERIFY
مرحله ۴ Business Rules    → Publish Process      → VERIFY
مرحله ۵ Performers        → Publish Organization* → VERIFY
مرحله ۶ Integrate         → Publish Integration* → VERIFY
مرحله ۷ Execute           → Publish کامل + تست   → VERIFY

* فقط اگر در آن مرحله تغییر دادید
```

> جزئیات هر فرایند در `SPEC.md` همان پوشه — این فایل **روش کار** است، نه spec.

---

## مرحله ۱ — Model Process

**Studio:** Wizard → **Model Process** · **منبع:** `SPEC.md` → Step 1

### کار شما

1. **[demo.bpmn.io](https://demo.bpmn.io/)** → Open → `{ProcessName}.bpmn`
2. دیاگرام را ببینید (task، gateway، lane، ترتیب)
3. Studio → New process → در Modeler **دستی** همان جریان را بکشید
4. **نام‌گذاری اجباری** — هر shape:
   - **Name** = `tskName` در SPEC (انگلیسی، مثلاً `SubmitLeave`)
   - **Display name** = فارسی در SPEC
5. از `Activity_1`, `Gateway_1` استفاده نکنید
6. Save در Modeler

### بازبینی

- [ ] تعداد task و transition با SPEC یکی است
- [ ] gateway و شاخه‌ها درست است
- [ ] همه `tskName` معنادارند

### Publish

- [ ] **Publish Process**

### Verify

```
مرحله ۱ تمام شد. VERIFY کن.
```

→ `STATUS.md` · انتظار: `WFCLASS`, `TASK`, `TRANSITION` در DB

---

## مرحله ۲ — Model Data

**Studio:** Wizard → **Model Data** · **منبع:** `SPEC.md` → Step 2

### کار شما

1. Entity بسازید (`entName` و Display در SPEC)
2. به فرایند وصل کنید (**context entity**)
3. همه attributeهای SPEC را اضافه کنید (`attribName` دقیقاً مثل SPEC)
4. **Type** را از لیست Studio انتخاب کنید (ستون «نوع Studio» در SPEC)

### انواع داده Studio (Bizagi 11.x)

**Common Types:**

| Studio | کاربرد |
|--------|--------|
| Boolean (yes-no) | بله/خیر |
| Date-time | تاریخ و زمان |
| String | متن کوتاه |
| Integer | عدد صحیح |
| Currency | مبلغ |
| File / Image | فایل / تصویر |

**More Types:** Extended Text (متن بلند)، Float، Real، Big/Small/Tiny Integer

**Entities / Collections:** ارتباط با entity دیگر — در این فرایند لازم نیست.

**نگاشت رایج spec → Studio:**

| در SPEC می‌نویسیم | در Studio انتخاب کن |
|-------------------|---------------------|
| Date | Date-time |
| Text | String (یا Extended Text) |
| Boolean | Boolean (yes-no) |
| Number | Integer / Float |

### بازبینی

- [ ] entity به فرایند لینک شده
- [ ] همه attributeها با نام صحیح

> **Validation** (مثل endDate ≥ startDate) اینجا نیست — **مرحله ۴** Business Rules.

### Publish

- [ ] **Publish Entity** (یا Publish Data Model)

> Publish Process مرحله ۱ **کافی نیست** — حتماً Publish Entity بزنید.

### Verify

```
مرحله ۲ تمام شد. VERIFY کن.
```

→ `STATUS.md` · انتظار: `ENTITY`, `ATTRIB`, `BAWFCLASS_ENTITY` در DB

---

## مرحله ۳ — Define Forms

**Studio:** Wizard → **Define Forms** · **منبع:** `SPEC.md` → Step 3

### کار شما

برای **هر task انسانی** در SPEC:

1. task را باز کنید → Edit form
2. attributeها را روی فرم بکشید (xpath خودکار می‌شود)
3. **Editable / Read-only** مطابق SPEC
4. Group و ترتیب فیلدها را بچینید
5. task تأیید: فیلدهای قبلی read-only + فیلدهای تصمیم editable

### بازبینی

- [ ] هر manual task فرم دارد
- [ ] xpathها `{Entity}.{field}` هستند
- [ ] فرم submit editable · فرم approval خلاصه + تصمیم

### Publish

- [ ] **Publish Process** (فرم‌ها با فرایند publish می‌شوند)

### Verify

```
مرحله ۳ تمام شد. VERIFY کن.
```

→ `STATUS.md` · انتظار: `TASK.idForm` پر شده · فرم در Work Portal رندر شود

---

## مرحله ۴ — Business Rules

**Studio:** Wizard → **Business Rules** · **منبع:** `SPEC.md` → Step 4

### کار شما

1. **شرط gateway:** روی transition بعد از gateway (جدول SPEC)
2. **Expression**ها را از SPEC کپی کنید — یا از Agent بخواهید
3. **Default** فیلدها (مثلاً `requestDate` = today، `employeeName` = کاربر جاری)
4. **Validation** — بخش «Validation» در SPEC Step 4:
   - `endDate >= startDate` (entity rule یا validation فرم)
   - `managerComment` اجباری وقتی `approved = false`
5. **Form rules** مطابق SPEC

### بازبینی

- [ ] هر شاخه gateway expression دارد
- [ ] xpath کامل: `{Entity}.field` نه فقط `field`

### Publish

- [ ] **Publish Process**

### Verify

```
مرحله ۴ تمام شد. VERIFY کن.
```

→ تست دستی در Studio یا بعد از case در مرحله ۷

---

## مرحله ۵ — Performers

**Studio:** Wizard → **Performers** · **منبع:** `SPEC.md` → Step 5

### کار شما

برای هر manual task در SPEC:

| نوع رایج | معنی |
|----------|------|
| Current user | خود درخواست‌دهنده |
| Boss of user | مدیر مستقیم |
| Role | نقش سازمانی (مثلاً HR) |

### بازبینی

- [ ] هر human task performer دارد
- [ ] نقش‌های جدید در Organization ساخته شده

### Publish

- [ ] **Publish Organization** — اگر نقش/کاربر عوض شد
- [ ] **Publish Process** — در صورت نیاز

### Verify

```
مرحله ۵ تمام شد. VERIFY کن.
```

→ بعد از case تست: work item در inbox درست

---

## مرحله ۶ — Integrate

**Studio:** Wizard → **Integrate** · **منبع:** `SPEC.md` → Step 6

### کار شما

- اگر SPEC می‌گوید **N/A** → این مرحله را رد کنید
- در غیر این صورت: connector، REST، ایمیل، … طبق SPEC

### Publish

- [ ] **Publish Integration** — فقط اگر چیزی اضافه کردید

---

## مرحله ۷ — Execute

**Studio:** Deploy / Publish · **منبع:** `SPEC.md` → Step 7

### چک‌لیست Publish نهایی

- [ ] Publish Process
- [ ] Publish Entity
- [ ] Publish Organization (اگر لازم بود)
- [ ] Publish Integration (اگر لازم بود)
- [ ] Recycle IIS app pool
- [ ] `BizAgi.Generated.dll` در `WebApplication/bin/`

### تست در Work Portal

1. case **جدید** بسازید (case قدیمی = شکل قدیمی فرایند)
2. سناریوهای test case در SPEC را اجرا کنید
3. هر task را تکمیل کنید تا به End برسد

### Verify

```
Publish کردم. VERIFY کن.
```

→ `STATUS.md` · `WORKITEM` مسیر case

---

## پیوست — نکات مهم

1. **SPEC ثابت** · **STATUS متغیر** — پیشرفت را از `STATUS.md` بخوانید
2. هر فرایند: `docs/processes/{ProcessName}/`
3. رمز در چت Agent ننویسید
4. گیر کردید؟ مرحله و task را بگویید + `طبق AGENTS.md عمل کن`

### درخواست خوب / ضعیف

| خوب | ضعیف |
|-----|------|
| «مرحله ۲ تمام شد، VERIFY کن» | «درست شد؟» (بدون گفتن مرحله) |
| «expression gateway بنویس» | «خودت بساز» |
| «case ۵ در ManagerApproval گیر کرد» | «مشکل داره» |

### FAQ

**باید AGENTS.md بخوانم؟** خیر — فقط «طبق AGENTS.md عمل کن».

**`.bpmn` چیست؟** دیاگرام مرجع — در bpmn.io ببینید، در Modeler بکشید.

**چرا Agent خودش نمی‌سازد؟** Studio + Publish دست شماست؛ Agent spec می‌دهد.

---

*اطلاعات این deployment → [README.md](./README.md)*
