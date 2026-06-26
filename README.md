# FridayProject

پروژه Bizagi BPM — محیط طراحی و اجرای فرایندها.

| مورد | مقدار |
|------|--------|
| Work Portal | http://DESKTOP-3IKIKUJ/FridayProject/ |
| نسخه | 11.2.5.1148 |

---

## مستندات

| فایل | مخاطب | محتوا |
|------|--------|--------|
| **[TEAM-GUIDE.md](./TEAM-GUIDE.md)** | اعضای تیم | هفت مرحله Wizard گام‌به‌گام + Cursor |
| **[AGENTS.md](./AGENTS.md)** | Agent (Cursor) | قرارداد فنی — در چت ارجاع دهید، نیازی به خواندن ندارید |

### شروع سریع

1. `TEAM-GUIDE.md` را بخوانید
2. در چت Agent بنویسید: **«طبق AGENTS.md عمل کن»**
3. نیاز فرایند را توضیح دهید

---

## ساختار فرایندها

```
docs/processes/{ProcessName}/
├── SPEC.md            ← طراحی (ثابت)
├── STATUS.md          ← پیشرفت + نتیجه verify
├── {ProcessName}.bpmn ← پیش‌نمایش در demo.bpmn.io
└── VERIFY.sql         ← کوئری تأیید DB
```
