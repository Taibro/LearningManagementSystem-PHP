## 📌 Summary
<!-- Brief description of the purpose of this PR and what was changed -->
- **Type**: 🚀 Feature | 🐛 Bugfix | ♻️ Refactor | 🔧 Chore | 📝 Docs | ⚡ Perf
- **Module Affected**:
  - [ ] `lms-be` (Laravel 13 API)
  - [ ] `lms-fe` (React 18 Vite Portals)
  - [ ] `lms-native` (React Native / Expo Mobile)
  - [ ] Infrastructure / CI/CD / Docker
- **Relates to Issue**: Fixes #

---

## 🛠️ Changes Details
<!-- Specific details of the changes made -->
### Backend (`lms-be`)
- [ ] New / Modified API Endpoints: `...`
- [ ] Service / Business Logic: `...`
- [ ] Database Migration / Seeding: `...`
- [ ] Checked: `classes` table mapped to `CourseClass` model (DO NOT use `Class.php`)
- [ ] Checked: PostgreSQL RLS session context (`school_id`, `user_id`, `role`) enforced

### Frontend (`lms-fe`)
- [ ] Portal: `SAAS Admin` | `School Admin` | `Lecturer` | `Student`
- [ ] New Page / Component: `...`
- [ ] API Integration: `...`

### Mobile (`lms-native`)
- [ ] Screen / Component: `...`
- [ ] State Management / Service: `...`

---

## 🔒 Security & Multi-Tenancy (PostgreSQL RLS + Keycloak OIDC)
- [ ] **Multi-Tenant Isolation**: Queries strictly respect `school_id` with zero cross-tenant data leakage
- [ ] **Database Connection**: Used correct connection: `pgsql` (enforces RLS) or `pgsql_owner` (migration/seed/admin)
- [ ] **Keycloak Auth**: Direct Access Grants / JWT claims compatible with roles (`SAAS_ADMIN`, `SCHOOL_ADMIN`, `LECTURER`, `STUDENT`)
- [ ] **Data Sanitization**: Input validation implemented; no passwords, tokens, or secrets exposed in logs/responses

---

## 🧪 Testing & CI Verification
<!-- Checks required by CI before merging -->
- [ ] **Backend CI**: `./vendor/bin/pest` & `./vendor/bin/phpstan analyse` passed
- [ ] **Frontend CI**: `npm run lint` & `npm run build` passed
- [ ] **Mobile CI**: `npm run lint` & `npx tsc --noEmit` & `npm test` passed
- [ ] **Manual Verification**: Verified API / UI flows on local or dev environment

---

## 📸 Proof of Work / Screenshots
<!-- Attach screenshots of successful API responses or of UI changes, DevTools network responses, or test execution logs -->
