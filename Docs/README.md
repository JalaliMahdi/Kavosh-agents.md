# Docs — طراحی و مستندسازی **حین و بعد** پیاده‌سازی

این بخش متعلق به **واحد طراحی فرایند (Bizagi)** است.

| مرحله | محل | محتوا |
|--------|-----|--------|
| **قبل طراحی** | [`ProcessDocKit/`](../ProcessDocKit/README.md) | صورتجلسه، تحلیل فرم، **شناسنامه** |
| **حین طراحی** | `Docs/processes/{ProcessKey}/` | SPEC، BPMN، verify |
| **بعد طراحی** | همان پوشه | STATUS، test case، **سند پیاده‌سازی** *(قالب بعداً)* |

---

## ProcessKey

نام پوشه = `wfClsName` (PascalCase انگلیسی) — **همان** ProcessKey در ProcessDocKit.

مثال: `BusinessTrip` · `WarehouseRequest`

---

## ساختار هر فرایند

```text
Docs/processes/{ProcessKey}/
├── SPEC.md              ← طراحی ۷ مرحله Wizard (ثابت؛ بدون verify)
├── STATUS.md            ← پیشرفت + نتیجه DB (بعد از هر Publish)
├── VERIFY.sql           ← کوئری‌های read-only
├── {ProcessKey}.bpmn    ← دیاگرام مرجع
└── (آینده) سند پیاده‌سازی   ← قالب بعداً اضافه می‌شود
```

**ورودی شروع طراحی:** `ProcessDocKit/processes/{ProcessKey}/deliverables/{ProcessKey}-شناسنامه.docx`

---

## چرخه کامل (چند فرایند در یک پروژه)

```text
ProcessDocKit/processes/BusinessTrip/     Docs/processes/BusinessTrip/
ProcessDocKit/processes/WarehouseRequest/  Docs/processes/WarehouseRequest/
         │                                           │
    (قبل) شناسنامه                          (بعد) SPEC · BPMN · STATUS · …
```

هر فرایند مسیر مستقل دارد؛ ProcessKey در هر دو درخت یکسان است.

جزئیات Agent: [`AGENTS.md`](../AGENTS.md)
