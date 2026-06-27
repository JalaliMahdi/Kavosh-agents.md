/* ============================================================
   VERIFY.sql — BusinessTrip (درخواست ماموریت)
   Read-only verification after Publish.
   Project: Test30  |  DB: Test30
   اجرا:
     sqlcmd -S "DESKTOP-3IKIKUJ\MSSQLSERVER2017" -d "Test30" -E -i VERIFY.sql
   ============================================================ */
SET NOCOUNT ON;

/* --- 0) WFClass --- */
PRINT '=== WFCLASS ===';
SELECT idWFClass, wfClsName, wfClsDisplayName
FROM   WFCLASS
WHERE  wfClsName = 'BusinessTrip' AND deleted = 0;

/* اگر idWorkflow را می‌خواهید، از WORKFLOW بگیرید (آخرین نسخه فعال) */
PRINT '=== WORKFLOW (versions) ===';
SELECT w.idWorkflow, w.idWfClass, w.wfClassVersion, w.wfEnabled
FROM   WORKFLOW w
       JOIN WFCLASS c ON c.idWFClass = w.idWfClass
WHERE  c.wfClsName = 'BusinessTrip'
ORDER  BY w.idWorkflow DESC;

/* --- 1) Tasks (Step 1 naming) --- */
PRINT '=== TASK ===';
SELECT t.idTask, t.tskName, t.tskDisplayName, t.idTaskType
FROM   TASK t
       JOIN WORKFLOW w  ON w.idWorkflow = t.idWorkflow
       JOIN WFCLASS  c  ON c.idWFClass  = w.idWfClass
WHERE  c.wfClsName = 'BusinessTrip' AND t.deleted = 0
ORDER  BY t.idTask;
/* اخطار: اگر tskName شبیه 'Activity_%' یا 'Gateway_1'/'Event_%' بود → Step 1 ناقص است */

/* --- 1b) Transitions --- */
PRINT '=== TRANSITION ===';
SELECT tr.idTransition, tr.idTaskFrom, tf.tskName AS fromTask,
       tr.idTaskTo, tt.tskName AS toTask
FROM   TRANSITION tr
       JOIN WORKFLOW w  ON w.idWorkflow = tr.idWorkflow
       JOIN WFCLASS  c  ON c.idWFClass  = w.idWfClass
       LEFT JOIN TASK tf ON tf.idTask = tr.idTaskFrom
       LEFT JOIN TASK tt ON tt.idTask = tr.idTaskTo
WHERE  c.wfClsName = 'BusinessTrip'
ORDER  BY tr.idTransition;

/* --- 1c) Transition conditions (Step 4 gateways) --- */
PRINT '=== TRANSITIONCONDITION ===';
SELECT tc.idTransitionCondition, tc.idTransition
FROM   TRANSITIONCONDITION tc
       JOIN TRANSITION tr ON tr.idTransition = tc.idTransition
       JOIN WORKFLOW w   ON w.idWorkflow = tr.idWorkflow
       JOIN WFCLASS  c   ON c.idWFClass  = w.idWfClass
WHERE  c.wfClsName = 'BusinessTrip';

/* --- 2) Entity + Attributes (Step 2) --- */
PRINT '=== ENTITY ===';
SELECT idEnt, entName, entDisplayName
FROM   ENTITY
WHERE  entName IN ('BusinessTrip','MissionType','TransportMode');

PRINT '=== ATTRIB (BusinessTrip) ===';
SELECT a.idAttrib, a.attribName, a.attribDisplayName, a.attribType, a.dataType
FROM   ATTRIB a
WHERE  a.idEnt = (SELECT idEnt FROM ENTITY WHERE entName = 'BusinessTrip')
ORDER  BY a.attribName;

/* --- 7) Runtime smoke (after running a test case) --- */
PRINT '=== WORKITEM (latest case) ===';
SELECT TOP 50 wi.idWorkItem, t.tskName, wi.idCase, wi.wiEntryDate, wi.wiSolutionDate
FROM   WORKITEM wi
       JOIN TASK t      ON t.idTask = wi.idTask
       JOIN WORKFLOW w  ON w.idWorkflow = t.idWorkflow
       JOIN WFCLASS  c  ON c.idWFClass  = w.idWfClass
WHERE  c.wfClsName = 'BusinessTrip'
ORDER  BY wi.idWorkItem DESC;
