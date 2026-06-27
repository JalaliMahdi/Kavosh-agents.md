# STATUS — BusinessTrip (درخواست ماموریت)

> این فایل با **هر بار verify بعد از Publish** به‌روز می‌شود. وضعیت طراحی در `SPEC.md` است.

## فاز جاری

**Phase C — Publish/Verify** (مرحله ۱ ساخته و Publish شد؛ verify از DB انجام شد ✓)

> آخرین تغییر طراحی: افزودن نوع تأمین نقلیه (عمومی/سازمانی)، نقش «مسئول تهیه بلیط» + task `BookTicket`، و رویداد مرزی لغو ماموریت حین تهیه بلیط (`CancelBooking` → `NotifyTicketOfficer` → `EndCancelled`).

## پیشرفت Wizard

| Step | عنوان | وضعیت | یادداشت |
|------|-------|-------|---------|
| 1 | Model Process | ✅ verify شد (DB) | ۲۰ task + ۲۲ transition مطابق طراحی؛ نام‌ها معنادار |
| 2 | Model Data | ✅ verify شد (DB) | ۳ entity + ۴۱ attribute مطابق طراحی؛ نام‌گذاری اصلاح شد |
| 3 | Define Forms | 🟡 ناقص | فرم‌ها ساخته شد؛ حالت فیلدها (فقط‌خواندنی/اجباری/قابل‌ویرایش) هنوز کامل نشده |
| 4 | Business Rules | ⏳ منتظر کاربر | شرط gateway + calculated در SPEC |
| 5 | Performers | ⏳ منتظر کاربر | نقش‌ها باید با org تایید شوند |
| 6 | Integrate | ⏳ منتظر کاربر | اعلان خودکار لغو به مسئول تهیه بلیط لازم است |
| 7 | Execute | ⏳ منتظر Publish | چک‌لیست در SPEC |

## نتیجه آخرین verify (DB)

- **تاریخ:** ۱۴۰۵/۰۳/۳۰ (۲۰ ژوئن ۲۰۲۶)
- **اتصال DB:** OK (read-only، `Test30`)
- **WFCLASS:** `idWFClass=1`, `wfClsName=BusinessTrip`. ⚠ `wfClsDisplayName=BusinessTrip` (انگلیسی) — Display name فارسی «درخواست ماموریت» ست نشده (اختیاری).
- **TASK:** ۲۰ ردیف، همه با `tskName` معنادار. بدون `Activity_1`/`Gateway_1`/`Event_1`. ✓
  - Start: `StartMission` (type 1) ✓
  - Manual (type 2): `SubmitMission`, `ManagerApproval`, `HSEReview`, `FinanceAdvance`, `AdminArrangement`, `BookTicket`, `NotifyTicketOfficer`, `SubmitReport`, `FinanceSettlement` (۹ تا)
  - Gateway واگرا (type 16): `Gateway_ManagerDecision`, `Gateway_FieldMission`, `Gateway_Advance`, `Gateway_TransportType`
  - Gateway همگرا/merge (type 9): `Gateway_FieldMerge`, `Gateway_AdvanceMerge`, `Gateway_TransportMerge`
  - End (type 17): `EndRejected`, `EndApproved`, `EndCancelled`
- **TRANSITION:** ۲۲ ردیف، دقیقاً مطابق جریان طراحی‌شده. ✓
  - مسیر لغو `BookTicket → NotifyTicketOfficer` با `idTransitionType=9` ثبت شده = همان رویداد مرزی interrupting (`CancelBooking`). بیزاجی رویداد مرزی را به‌صورت TASK مستقل نگه نمی‌دارد، بلکه به‌شکل transition خاص از task مبدأ ذخیره می‌کند — به همین دلیل ۲۰ task (نه ۲۱) داریم و ساختار کامل است.
- **WORKITEM:** — (هنوز case تستی اجرا نشده)

### نتیجه‌گیری مرحله ۱

مدل فرایند **کامل و منطبق بر SPEC** است. تنها نکته‌ی اختیاری: ست‌کردن Display name فارسی روی WFClass.

## نتیجه verify مرحله ۲ — Model Data (۱۴۰۵/۰۳/۳۰)

- **ENTITY:** `BusinessTrip` (idEnt=10001), `MissionType` (10002), `TransportMode` (10003) ✓
- **ATTRIB:** هر ۴۱ attribute طراحی‌شده موجود و نوع‌ها درست:
  - String→`NVARCHAR(50)` · Date-time→`DATETIME` · Boolean→`BIT` · Integer→`INT` · Extended Text→`NTEXT` · Related→`BIGINT` (با `idEntRelated` صحیح)
  - رابطه‌ها: `requester`→WFUSER ✓ · `cancelledBy`→WFUSER ✓ · `MissionType`→MissionType ✓ · `TransportMode`→TransportMode ✓
- **نام‌گذاری attribute‌ها (بازبینی نهایی پس از اصلاح کاربر در مدل):**

| attribName نهایی در DB | وضعیت |
|------------------------|-------|
| `missionType` (Related→MissionType) | ✅ camelCase صحیح |
| `transportMode` (Related→TransportMode) | ✅ camelCase صحیح |
| `positions` | ✅ عمدی — `position` کلمه کلیدی رزروشده بیزاجی است |

> xpath مراحل ۳ و ۴: `BusinessTrip.missionType`، `BusinessTrip.transportMode`، `BusinessTrip.positions`. `SPEC.md` با این نام‌ها هماهنگ است.

### نتیجه‌گیری مرحله ۲

مدل داده **کامل و منطبق** است؛ نام‌گذاری attribute‌ها در مدل اصلاح و با SPEC هماهنگ شد.

## وضعیت مرحله ۳ — Define Forms (۱۴۰۵/۰۳/۳۰)

- **انجام‌شده:** فرم هر task ساخته شد (به گفته کاربر).
- **🟡 باقی‌مانده (کاربر بعداً تکمیل می‌کند):** تنظیم **حالت فیلدها** در هر فرم طبق ستون «وضعیت» در `SPEC.md`:
  - فیلدهای **فقط‌خواندنی** (read-only) — مثل اطلاعات درخواست در فرم‌های تایید مدیر/HSE/مالی.
  - فیلدهای **اجباری** (required) — مثل `missionType`, `missionPurpose`, `isPublicTransport`, تصمیم‌ها.
  - فیلدهای **قابل‌ویرایش/نمایش شرطی** — مثل `advanceAmount` (visible if `advanceRequested=true`)، `accommodationDetails` (visible if `needsAccommodation=true`).
- مرجع کامل حالت هر فیلد: بخش **Step 3 — Define Forms** در `SPEC.md`.
- توجه: تغییر فرم → bump `formsVersion` → Publish مجدد.

## اقدام بعدی (کاربر)

1. (اختیاری) ست‌کردن Display name فارسی «درخواست ماموریت» روی WFClass.
2. (اختیاری) افزودن مقادیر پارامتری به `MissionType` (درون‌شهری/برون‌شهری/خارج کشور) و `TransportMode` (خودرو سازمانی/شخصی/اتوبوس/قطار/هواپیما).
3. شروع **مرحله ۳ — Define Forms**: فرم هر task طبق `SPEC.md` (با xpath اصلاح‌شده).
4. پس از ساخت فرم‌ها → Publish → اطلاع به Agent برای بازبینی.
