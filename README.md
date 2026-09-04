# WerkLink SA — Online Starter

This package is the production-oriented starter for the next phase.

## What is included
- Browser app starter with Supabase JS CDN
- Login/register UI
- Worker/business role selection
- Job browsing
- Job posting form
- SQL schema with Row Level Security policies
- Clear environment/configuration placeholders

## Setup
1. Create a Supabase project.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. Copy your project URL and publishable key into `index.html` where indicated.
4. Enable Email/Password authentication in Supabase Auth.
5. Host the folder on an HTTPS static host.
6. Never put a Supabase secret/service-role key in the browser.

This starter is intentionally not pretending to be fully deployed: the database must be connected to your own Supabase project before real users can use it.
