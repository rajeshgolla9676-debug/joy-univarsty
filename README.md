# Student Portal

A responsive student portal template using HTML, CSS, JavaScript, Supabase Authentication, and PostgreSQL. This is an independent student project and is not an official Joy University service.

## Included
- Public landing page and responsive layouts
- Student registration with profile metadata
- Email/password login and logout
- Password recovery and reset pages
- Student dashboard and profile editing
- Role-protected administrator view with search and CSV export
- PostgreSQL schema, signup trigger, constraints, indexes, and RLS policies
- Privacy and terms starter pages, Vercel configuration, and environment example

## Setup
1. Create a project in Supabase.
2. Open the Supabase SQL Editor and run the complete database/schema.sql file.
3. In Supabase Project Settings > API, copy the project URL and publishable key (or legacy anon key).
4. Edit assets/js/config.js and replace the two placeholder values. This file is loaded by the browser, so use only the public publishable/anon key. Never put a service-role or secret key in frontend code.
5. In Supabase Authentication > URL Configuration, set the Site URL to your local/deployed website origin and add redirect URLs for /login.html and /reset-password.html.
6. Configure email confirmation and email templates as needed.
7. Run locally with a static server, for example: npx serve .
8. Register a test student and verify the profile row is created by the database trigger.
9. To assign the first administrator, sign up the intended account, identify its UUID in Supabase Auth users, then run the commented SQL statement at the bottom of database/schema.sql with that UUID. Only a trusted project owner should do this.
10. Push to GitHub, import the repository into Vercel, and deploy from the repository root. No build command is needed for these static HTML files.

## Security notes and limitations
- Supabase Auth manages passwords; the profile table does not store them.
- RLS is enabled on application tables. Students should only see their own profile; administrator access uses the database role table.
- Signup always assigns the student role and ignores client-supplied role values.
- The admin view currently supports read/search/export of records permitted by RLS. Suspend/restore, destructive actions, audit-write APIs, and other privileged administrative operations are not implemented.
- The admin query is capped at 500 rows and uses browser-side search. Large deployments should implement server-side pagination.
- Before using real student data, review RLS policies, test with multiple accounts, confirm SQL grants are correct, and obtain any required institutional/privacy approval. This is a starter project, not a security audit.

## Manual test checklist
- [ ] Student registration and duplicate student ID behavior
- [ ] Email verification and redirect URL behavior
- [ ] Valid/invalid login and logout
- [ ] Password recovery and password reset
- [ ] Dashboard loads saved profile after refresh
- [ ] Profile edits persist
- [ ] Student A cannot read/update Student B's profile
- [ ] Student cannot assign themselves an admin role
- [ ] Only authorized admins can list other profiles
- [ ] Test mobile layout, browser console, and production redirects

## Troubleshooting
- Setup warning: configure assets/js/config.js.
- Profile query error: ensure database/schema.sql completed successfully.
- Email/recovery link failure: check Supabase Auth URL allow-list and email delivery settings.
- Admin denied: verify the intended account's role assignment in Supabase; do not assign roles from browser code.
- Deployment not updated: verify Vercel is connected to the intended GitHub branch and redeploy.

Official docs: https://supabase.com/docs/guides/auth/redirect-urls and https://vercel.com/docs.
