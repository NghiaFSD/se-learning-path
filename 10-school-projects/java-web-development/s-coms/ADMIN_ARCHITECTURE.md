# S-COMS Admin Architecture

This document explains the Admin area of S-COMS for humans and AI assistants. Read this file before changing Admin code.

The project is a Java Servlet/JSP web application using SQL Server and Tomcat 10.1/Jakarta.

## 1. Admin Module Scope

The Admin module handles:

- Dashboard analytics and quick operational data.
- Account management for Admin, Receptionist, Doctor, and Patient accounts.
- Medical service catalog management.
- Doctor schedule management, manual scheduling, transfer, cancellation, and AI scheduling.
- Patient flow for today's appointments, check-in, start consultation, complete consultation, and no-show handling.
- Emergency routing when a patient needs to be reassigned to another doctor.
- Revenue and visit reports.

Main URL:

- `/admin`

Main controller:

- `src/java/com/diabetes/monitoring/admin/AdminServlet.java`

Views:

- `web/admin/dashboard.jsp`
- `web/admin/users.jsp`
- `web/admin/services.jsp`
- `web/admin/schedule-management.jsp`
- `web/admin/reports.jsp`
- `web/admin/exception-routing.jsp`
- `web/admin/health-records.jsp`
- `web/admin/fragments/sidebar.jspf`

## 2. Package Layout

Current Admin packages:

```text
com.diabetes.monitoring.admin
├── AdminServlet.java
├── analytics
├── management
├── scheduling
├── patientflow
└── common
```

### `admin`

`AdminServlet` is the only Admin entry servlet. It checks session access and delegates each `action` to the correct handler.

Important rules:

- Only users with role `admin` can access this servlet.
- POST requests must pass CSRF validation through `CsrfUtil.isValid(request)`.
- JSON/AJAX requests receive JSON errors.
- Normal page requests redirect to login or dashboard depending on context.

### `admin.analytics`

Files:

- `AdminAnalyticsHandler.java`
- `AdminAnalyticsService.java`
- `AdminAnalyticsDAO.java`

Internal classes in these files:

- `AdminDashboardHandler`
- `AdminDashboardService`
- `AdminDashboardDAO`
- `AdminReportHandler`
- `AdminReportService`
- `AdminReportDAO`

Responsibilities:

- Load dashboard summary cards.
- Load today's clinic queue status.
- Load chart data for revenue, visits, patient flow, appointment statuses.
- Load report pages and report detail modals.
- Load invoice item detail for reports.

Business rules:

- Revenue only counts `Invoice.status = 'Paid'`.
- Visit counts only completed appointments.
- Dashboard queue excludes cancelled and no-show patients from active load.

### `admin.management`

Files:

- `AdminManagementHandler.java`
- `AdminManagementService.java`
- `AdminManagementDAO.java`

Internal classes in these files:

- `AdminAccountHandler`
- `AdminAccountService`
- `AdminAccountDAO`
- `AdminMedicalServiceHandler`
- `AdminMedicalServiceService`
- `AdminMedicalServiceDAO`

Responsibilities:

- List, filter, create, update, lock, reactivate, and delete accounts.
- Edit role-specific profile data for Patient and Doctor accounts.
- Manage medical services: create, update, activate/deactivate, delete.
- Serve quick account and service data for dashboard widgets.

Business rules:

- Allowed roles are validated before insert/update.
- Allowed account statuses are validated before insert/update.
- Deleting an account must respect dependent domain data.
- Medical service status is `Active` or `Inactive`.
- Medical service type is usually `Examination` or `Lab_Test`.

### `admin.scheduling`

Files:

- `AdminSchedulingHandler.java`
- `AdminSchedulingService.java`
- `AdminSchedulingDAO.java`
- `AdminScheduleConstraintValidator.java`

Internal classes in these files:

- `AdminScheduleHandler`
- `AdminScheduleService`
- `AdminScheduleDAO`
- `AdminAiSchedulingHandler`
- `AdminAiSchedulingService`
- `AdminAiSchedulingDAO`

Responsibilities:

- Display and filter doctor schedules.
- Create, update, delete, cancel, and transfer schedules.
- Load schedule detail and appointment list for a schedule.
- Provide transfer candidates.
- Create schedules using Gemini AI suggestions plus backend validation.
- Validate schedule constraints before insertion.

Important business rules:

- A doctor cannot have duplicate schedule slots.
- A doctor cannot have overlapping schedule slots.
- Schedule max patients must be positive.
- Online quota defaults to 60% of `max_patients`, while keeping reserved slots for staff and walk-in booking.
- A schedule with appointments should be cancelled instead of hard deleted.
- AI scheduling suggestions must be validated by backend constraints before insert.
- Local fallback scheduling is used when Gemini fails or returns invalid suggestions.

Online quota formula:

```java
if (maxPatients <= 1) {
    onlineQuota = maxPatients;
} else {
    onlineQuota = (int) Math.ceil(maxPatients * 0.6);
    if (onlineQuota >= maxPatients) {
        onlineQuota = maxPatients - 1;
    }
    onlineQuota = Math.max(1, onlineQuota);
}
reservedSlots = maxPatients - onlineQuota;
```

Expected examples:

| max_patients | online_quota | reserved_slots |
| ---: | ---: | ---: |
| 1 | 1 | 0 |
| 2 | 1 | 1 |
| 3 | 2 | 1 |
| 4 | 3 | 1 |
| 5 | 3 | 2 |
| 8 | 5 | 3 |
| 10 | 6 | 4 |

### `admin.patientflow`

Files:

- `AdminPatientFlowHandler.java`
- `AdminPatientFlowService.java`
- `AdminPatientFlowDAO.java`

Internal classes in these files:

- `AdminAppointmentHandler`
- `AdminAppointmentWorkflowService`
- `AdminAppointmentDAO`
- `AdminEmergencyRoutingHandler`
- `AdminEmergencyRoutingService`
- `AdminEmergencyRoutingDAO`

Responsibilities:

- Load today's appointment list.
- Load today's waiting patients.
- Load a doctor's queue detail.
- Load appointments inside a selected schedule.
- Check in appointments.
- Start appointments.
- Complete appointments.
- Mark late waiting appointments as `No_Show`.
- Load emergency routing page and candidate doctors.
- Reassign appointments to another doctor.

Appointment workflow:

```text
Waiting -> Checked_In -> In_Progress -> Completed
Waiting after cutoff -> No_Show
Any active appointment may become Cancelled through cancellation flows.
```

Slot-counting rules:

- Counted statuses: `Waiting`, `Checked_In`, `In_Progress`, `Completed`.
- Not counted: `Cancelled`, `No_Show`.
- `bookedCount` counts all counted statuses.
- `onlineBookedCount` counts counted statuses where booking source is online.

Online booking rule:

- Patient online booking is blocked when `onlineBookedCount >= onlineQuota`.
- Staff, receptionist, and walk-in booking may still use reserved slots while `bookedCount < maxPatients`.

### `admin.common`

Files:

- `AdminRepository.java`
- `AdminJsonUtil.java`
- `AdminStatusMapper.java`
- `ApiResponseDTO.java`
- `ReportSeriesDTO.java`

Responsibilities:

- `AdminRepository`: central SQL access for Admin read/write operations.
- `AdminJsonUtil`: manual JSON serialization helpers for Admin AJAX responses.
- `AdminStatusMapper`: status normalization, counting status rules, and Vietnamese labels.
- `ApiResponseDTO`: simple JSON response model.
- `ReportSeriesDTO`: report chart point with `period` and `value`.

Important note:

- Most Admin DAO classes are thin wrappers around `AdminRepository`.
- `AdminRepository` is currently large because it centralizes Admin SQL after package refactor.
- If refactoring later, split it by module: dashboard, reports, accounts, services, schedules, appointment workflow, emergency routing.

## 3. Request Routing

All Admin pages and AJAX calls go through `/admin?action=...`.

### GET actions

| Action | Handler | View/Response |
| --- | --- | --- |
| empty, `dashboard` | `analyticsHandler.loadDashboard` | `dashboard.jsp` |
| `reports` | `analyticsHandler.loadReports` | `reports.jsp` |
| `getReportDetail` | `analyticsHandler.loadReportDetailByPeriod` | JSON |
| `getInvoiceItems` | `analyticsHandler.loadInvoiceItems` | JSON |
| `listUsers` | `managementHandler.loadAccounts` | `users.jsp` |
| `getAccountProfile` | `managementHandler.loadAccountProfile` | JSON |
| `manageServices` | `managementHandler.loadServices` | `services.jsp` |
| `dashboardChartData` | `analyticsHandler.loadDashboardChartData` | JSON |
| `quickAccountsData` | `analyticsHandler.loadQuickAccountsData` | JSON |
| `quickRevenueData` | `analyticsHandler.loadQuickRevenueData` | JSON |
| `quickServicesData` | `analyticsHandler.loadQuickServicesData` | JSON |
| `quickAppointmentsData` | `analyticsHandler.loadQuickAppointmentsData` | JSON |
| `schedule`, `manageSchedules` | `schedulingHandler.loadSchedules` | `schedule-management.jsp` |
| `getSchedule` | `schedulingHandler.loadScheduleDetail` | JSON |
| `getTransferCandidates` | `schedulingHandler.loadTransferCandidates` | JSON |
| `exception`, `viewHealthRecords` | `patientFlowHandler.loadExceptionRouting` | `exception-routing.jsp` |
| `getDoctorQueueDetail` | `patientFlowHandler.loadDoctorQueueDetail` | JSON |
| `getTodayAppointments` | `patientFlowHandler.loadTodayAppointments` | JSON |
| `getTodayWaiting` | `patientFlowHandler.loadTodayWaiting` | JSON |
| `scheduleAppointments` | `patientFlowHandler.loadScheduleAppointments` | JSON |
| `aiCreateSchedules` | `schedulingHandler.aiCreateSchedules` | JSON |

### POST actions

| Action | Handler | Purpose |
| --- | --- | --- |
| `createAccount` | `managementHandler.createAccount` | Create account |
| `updateAccountRole` | `managementHandler.updateAccountRole` | Change role |
| `lockAccount` | `managementHandler.updateAccountStatus(..., "locked")` | Lock account |
| `reactivateAccount` | `managementHandler.updateAccountStatus(..., "active")` | Reactivate account |
| `deleteAccount` | `managementHandler.deleteAccount` | Delete account |
| `updateAccountProfile` | `managementHandler.updateAccountProfile` | Edit profile by role |
| `ajaxToggleAccountStatus` | `managementHandler.ajaxToggleAccountStatus` | JSON status toggle |
| `createService` | `managementHandler.createService` | Create medical service |
| `updateService` | `managementHandler.updateService` | Update medical service |
| `updateServiceStatus`, `ajaxToggleServiceStatus` | `managementHandler.updateServiceStatus` | Status toggle |
| `deleteService` | `managementHandler.deleteService` | Delete service |
| `createSchedule` | `schedulingHandler.createSchedule` | Create doctor schedule |
| `updateSchedule` | `schedulingHandler.updateSchedule` | Update doctor schedule |
| `deleteSchedule` | `schedulingHandler.deleteSchedule` | Delete schedule |
| `cancelSchedule` | `schedulingHandler.cancelSchedule` | Cancel schedule |
| `transferSchedule` | `schedulingHandler.transferSchedule` | Transfer schedule to another doctor |
| `aiCreateSchedules` | `schedulingHandler.aiCreateSchedules` | Create AI-generated schedules |
| `emergencyReassign` | `patientFlowHandler.emergencyReassign` | Reassign appointment |
| `checkInAppointment` | `patientFlowHandler.updateAppointmentWorkflowStatus(..., "checkIn")` | Waiting -> Checked_In |
| `startAppointment` | `patientFlowHandler.updateAppointmentWorkflowStatus(..., "start")` | Checked_In -> In_Progress |
| `completeAppointment` | `patientFlowHandler.updateAppointmentWorkflowStatus(..., "complete")` | In_Progress -> Completed |

## 4. View Map

### `dashboard.jsp`

Shows:

- Account summary.
- Revenue and visit summary.
- Today clinic queue.
- Today schedule list.
- Patient flow chart.
- Revenue by service type.
- Appointment status chart.
- Quick data modals.

Main data source:

- `AdminAnalyticsHandler`
- `AdminAnalyticsService`
- `AdminRepository`

### `users.jsp`

Shows:

- Account list with search, role filter, and status filter.
- Create account form.
- Lock/reactivate/delete actions.
- Edit account profile modal.

Main data source:

- `AdminManagementHandler`
- `AdminManagementService`
- `AdminRepository`

### `services.jsp`

Shows:

- Medical service list.
- Create service form.
- Edit service modal.
- Activate/deactivate/delete actions.

Main data source:

- `AdminManagementHandler`
- `AdminManagementService`
- `AdminRepository`

### `schedule-management.jsp`

Shows:

- Schedule filters by department, doctor, date.
- Schedule table with load, online quota, reserved slots, and status.
- Create/edit schedule modal.
- Transfer schedule modal.
- AI scheduling panel.
- Schedule appointment modal.

Main data source:

- `AdminSchedulingHandler`
- `AdminSchedulingService`
- `AdminScheduleConstraintValidator`
- `AdminRepository`

Important UI display rules:

- Online quota column displays `onlineBookedCount / onlineQuota`.
- Reserved slots display `max_patients - online_quota`.
- Badge:
  - `Còn slot online` when `onlineBookedCount < onlineQuota`.
  - `Hết slot online` when `onlineBookedCount == onlineQuota`.
  - `Vượt quota online` when `onlineBookedCount > onlineQuota`.

### `reports.jsp`

Shows:

- Revenue report.
- Visit report.
- Report charts by day/month/year.
- Detail modal by selected period.
- Invoice item modal.

Main data source:

- `AdminAnalyticsHandler`
- `AdminReportService`
- `AdminRepository`

Report rules:

- Revenue counts paid invoices only.
- Visit report counts completed appointments only.

### `exception-routing.jsp`

Shows:

- Appointments needing routing attention.
- Candidate doctors for reassignment.
- Emergency reassignment form.

Main data source:

- `AdminPatientFlowHandler`
- `AdminEmergencyRoutingService`
- `AdminRepository`

## 5. Frontend JS Map

Admin JavaScript is separated from JSP pages under:

```text
web/assets/js/admin/
├── dashboard.js
├── users.js
├── services.js
├── schedule-management.js
└── reports.js
```

JSP pages should only keep small configuration blocks for server-side values:

```jsp
<script>
    window.AdminConfig = {
        contextPath: '${pageContext.request.contextPath}',
        csrfToken: '${sessionScope.csrfToken}'
    };
</script>
```

Rules:

- Do not put large page logic directly inside JSP files.
- Put page behavior in the matching file under `web/assets/js/admin/`.
- Pass JSP values through `window.AdminConfig` or a page-specific object such as `window.AdminDashboardData`.
- Keep `exception-routing.jsp` without a JS file until it has real page behavior to extract.

JS ownership:

- `dashboard.js`: dashboard charts, quick modals, queue modals.
- `users.js`: account profile modal and confirmation modal.
- `services.js`: edit medical service modal.
- `reports.js`: report charts, report detail modal, invoice detail modal.
- `schedule-management.js`: transfer schedule, edit schedule, AI scheduling, appointment modal, quota badges.

## 6. Database Tables Used By Admin

Important tables:

- `Account`: login identity, role, account status.
- `Patient`: patient profile linked to account.
- `Doctor`: doctor profile linked to account.
- `Medical_Service`: service catalog.
- `Doctor_Schedule`: doctor work date, time slot, capacity, status, online quota.
- `Appointment`: patient appointment, doctor, schedule, queue number, booking source, workflow status.
- `Invoice`: billing header, payment method, paid/pending status.
- `Invoice_Detail`: billing lines and service references.
- `Medical_record`: doctor-created medical record tied to appointment.
- `Healthy_Record`: diabetes health metrics and AI/doctor processing state.
- `Doctor_AI`: AI analysis result for health records.
- `Record_Transfer_History`: transfer history for health records.

Admin-related migrations:

- `database/sync_project_swp_to_swp_schema.sql`
- `database/migration_add_no_show_status_mssql.sql`
- `database/migration_fix_online_quota_60_percent_mssql.sql`

Important schema additions compared with older scripts:

- `Doctor_Schedule.online_quota`
- `Appointment.booking_source`
- `Appointment.status` supports `Checked_In`, `In_Progress`, `No_Show`, `Cancelled`, `Completed`, `Waiting`
- `Doctor_Schedule.status` may be refreshed to `Available`, `Full`, `Expired`, or `Cancelled`
- Invoice and invoice detail fields used by revenue reports

## 7. Status Rules

### Appointment statuses

Canonical statuses:

- `Waiting`
- `Checked_In`
- `In_Progress`
- `Completed`
- `Cancelled`
- `No_Show`

Vietnamese labels:

- `Waiting` -> `Đã đặt lịch`
- `Checked_In` -> `Đã check-in`
- `In_Progress` -> `Đang khám`
- `Completed` -> `Đã hoàn tất`
- `Cancelled` -> `Đã hủy`
- `No_Show` -> `Không đến`

Statuses that occupy a schedule slot:

- `Waiting`
- `Checked_In`
- `In_Progress`
- `Completed`

Statuses that do not occupy a schedule slot:

- `Cancelled`
- `No_Show`

### Schedule statuses

Canonical statuses:

- `Available`
- `Full`
- `Expired`
- `Cancelled`

Refresh rule:

```text
If schedule is Cancelled -> keep Cancelled
Else if end time has passed -> Expired
Else if bookedCount >= max_patients -> Full
Else -> Available
```

`bookedCount` must exclude `Cancelled` and `No_Show`.

## 8. Schedule Capacity Rules

### bookedCount

Correct SQL concept:

```sql
SELECT COUNT(*) AS booked_count
FROM Appointment
WHERE schedule_id = ?
  AND LOWER(status) IN ('waiting', 'checked_in', 'in_progress', 'completed');
```

### onlineBookedCount

Correct SQL concept:

```sql
SELECT COUNT(*) AS online_booked_count
FROM Appointment
WHERE schedule_id = ?
  AND LOWER(LTRIM(RTRIM(COALESCE(booking_source, '')))) = 'online'
  AND LOWER(status) IN ('waiting', 'checked_in', 'in_progress', 'completed');
```

### Online booking

Online patient booking is allowed only when:

```text
onlineBookedCount < onlineQuota
schedule is not Cancelled
schedule is not Expired
schedule has not passed new-patient cutoff time
```

When online booking is full, show:

```text
Ca này đã hết slot đặt online. Vui lòng chọn ca khác hoặc liên hệ lễ tân để được hỗ trợ.
```

### Staff booking

Staff/receptionist/walk-in booking can use reserved slots when:

```text
bookedCount < maxPatients
schedule is not Cancelled
schedule is not Expired
schedule has not passed new-patient cutoff time
```

## 9. AI Scheduling

AI scheduling lives in:

- `AdminSchedulingHandler.java`
- `AdminSchedulingService.java`
- `AdminSchedulingDAO.java`
- `AdminRepository.java`
- `src/java/com/diabetes/monitoring/util/GeminiSchedulingService.java`

Flow:

```text
schedule-management.jsp
-> /admin?action=aiCreateSchedules
-> AdminServlet
-> AdminSchedulingHandler
-> AdminAiSchedulingService
-> GeminiSchedulingService
-> AdminScheduleConstraintValidator
-> AdminRepository insert
```

Important rules:

- Gemini suggests candidate schedules.
- Backend validates each candidate before inserting.
- Duplicate and overlapping schedules must be rejected.
- If Gemini fails, local fallback scheduling can create schedules.
- Inserted rows should include a source marker where available, such as `Gemini AI` or local fallback.

## 10. Common Development Checklist

When changing Admin code:

1. Start from `AdminServlet` to find the `action`.
2. Follow the handler method.
3. Follow the service method.
4. Follow DAO/repository SQL.
5. Check the JSP that renders the result.
6. Check `AdminStatusMapper` when status labels or counting rules are involved.
7. Check `AdminScheduleConstraintValidator` when schedule rules are involved.
8. Re-run compile with `ant compile`.

When changing schedule capacity:

1. Check `calculateDefaultOnlineQuota`.
2. Check `getBookedCountBySchedule`.
3. Check `getOnlineBookedCountBySchedule`.
4. Check `canBookOnline`.
5. Check `canBookByStaff`.
6. Check `refreshDoctorScheduleStatusFromAppointments`.
7. Check `schedule-management.jsp` quota display.

When changing reports:

1. Revenue must use paid invoices only.
2. Visits must use completed appointments only.
3. Detail modal and chart data must use the same date granularity.

When changing appointment workflow:

1. Respect `Waiting -> Checked_In -> In_Progress -> Completed`.
2. Do not count `No_Show` and `Cancelled` as occupied slots.
3. Refresh schedule status after workflow-changing actions.
4. Keep Vietnamese labels in `AdminStatusMapper`.

## 11. Known Design Notes

- The package structure is already simplified into five Admin packages.
- Some source files contain one public facade class and package-private internal classes. This was done to reduce package/file sprawl after the Admin refactor.
- `AdminRepository` is intentionally central right now, but it is large. Future cleanup can split it into repositories by domain.
- `UserDAO.java` outside the Admin package is also large and handles login, account, doctor, patient, health record, assignment, and AI analysis. Do not confuse it with the Admin package design.
- Build artifacts under `build/` and `dist/` are generated. Source of truth is under `src/java`, `web/admin`, and `database`.

## 12. Important Files

Controller:

- `src/java/com/diabetes/monitoring/admin/AdminServlet.java`

Analytics:

- `src/java/com/diabetes/monitoring/admin/analytics/AdminAnalyticsHandler.java`
- `src/java/com/diabetes/monitoring/admin/analytics/AdminAnalyticsService.java`
- `src/java/com/diabetes/monitoring/admin/analytics/AdminAnalyticsDAO.java`

Management:

- `src/java/com/diabetes/monitoring/admin/management/AdminManagementHandler.java`
- `src/java/com/diabetes/monitoring/admin/management/AdminManagementService.java`
- `src/java/com/diabetes/monitoring/admin/management/AdminManagementDAO.java`

Scheduling:

- `src/java/com/diabetes/monitoring/admin/scheduling/AdminSchedulingHandler.java`
- `src/java/com/diabetes/monitoring/admin/scheduling/AdminSchedulingService.java`
- `src/java/com/diabetes/monitoring/admin/scheduling/AdminSchedulingDAO.java`
- `src/java/com/diabetes/monitoring/admin/scheduling/AdminScheduleConstraintValidator.java`

Patient flow:

- `src/java/com/diabetes/monitoring/admin/patientflow/AdminPatientFlowHandler.java`
- `src/java/com/diabetes/monitoring/admin/patientflow/AdminPatientFlowService.java`
- `src/java/com/diabetes/monitoring/admin/patientflow/AdminPatientFlowDAO.java`

Common:

- `src/java/com/diabetes/monitoring/admin/common/AdminRepository.java`
- `src/java/com/diabetes/monitoring/admin/common/AdminJsonUtil.java`
- `src/java/com/diabetes/monitoring/admin/common/AdminStatusMapper.java`
- `src/java/com/diabetes/monitoring/admin/common/ApiResponseDTO.java`
- `src/java/com/diabetes/monitoring/admin/common/ReportSeriesDTO.java`

Views:

- `web/admin/dashboard.jsp`
- `web/admin/users.jsp`
- `web/admin/services.jsp`
- `web/admin/schedule-management.jsp`
- `web/admin/reports.jsp`
- `web/admin/exception-routing.jsp`
- `web/admin/health-records.jsp`
- `web/admin/fragments/sidebar.jspf`

Admin JS:

- `web/assets/js/admin/dashboard.js`
- `web/assets/js/admin/users.js`
- `web/assets/js/admin/services.js`
- `web/assets/js/admin/schedule-management.js`
- `web/assets/js/admin/reports.js`

Database:

- `database/SWP .sql`
- `database/sync_project_swp_to_swp_schema.sql`
- `database/migration_add_no_show_status_mssql.sql`
- `database/migration_fix_online_quota_60_percent_mssql.sql`

## 13. Quick Mental Model

Use this mental model when debugging:

```text
JSP page or fetch()
-> /admin?action=...
-> AdminServlet
-> module Handler
-> module Service
-> module DAO
-> AdminRepository
-> SQL Server
-> back to JSP or JSON
```

For most bugs, the fastest path is:

```text
Find action in JSP
-> find action in AdminServlet
-> inspect handler method
-> inspect repository method
-> verify DB status/counting rule
```
