ROOM WORK — V6 DATE-MARKING CELLS + NETLIFY SHARED SETTINGS + MOBILE + EXPORT

WHAT CHANGED
- Only two tabs: Excel and Settings.
- No text-entry fields and no checkbox icons. Tap a task/person cell to display the confirmed date (DD-MM); tap it again to clear the mark.
- Select Today, Tomorrow, or any date; confirm it. The confirmed date is displayed above the spreadsheet. Marked cells show that date as DD-MM.
- Export Excel (.xlsx) and landscape PDF.
- Mobile-friendly large touch targets, horizontal scrolling, and landscape layout.
- Supabase URL, public anon/publishable key, project name, and owner PIN are saved centrally using Netlify Functions + Netlify Blobs. The owner configures these once; other devices load the same settings automatically.
- The owner PIN is verified server-side and its salted scrypt hash is stored in Netlify Blobs. The PIN is not stored in browser localStorage.

DEPLOY ON NETLIFY (IMPORTANT)
This version uses a Netlify Function and Netlify Blobs. It cannot be deployed as a simple drag-and-drop static folder because that does not deploy the server function.
1. Extract this ZIP.
2. Upload the extracted folder to a GitHub repository.
3. In Netlify, choose Add new site > Import an existing project, connect that GitHub repository, and deploy.
4. Netlify should detect netlify.toml and install @netlify/blobs from package.json. Publish directory is . and functions directory is netlify/functions.
5. After deploy, open the live website. The first person to open Settings should create the owner PIN immediately. This claims the one-time owner setup.
6. Unlock Settings, enter the Supabase Project URL and anon/public or publishable key, and Save & connect.
7. Other devices opening the same Netlify URL will automatically load the shared settings. They do not need to enter the URL or key.

SUPABASE
1. Run supabase-schema.sql in Supabase SQL Editor.
2. The app uses tables room_work_cells and room_work_dates.
3. Realtime must be enabled for these tables (the SQL attempts to add them to supabase_realtime).
4. Only enter the Supabase anon/public or publishable key. Never use service_role or a secret key in the browser.
5. This is a public no-login spreadsheet. Its SQL policies allow anyone who can reach the site to read and edit the room-work data. Do not put private or sensitive information in it.

OWNER PIN
- Use a strong passphrase (8+ characters; preferably longer than a short numeric PIN).
- First-time setup is claimed by the first person who creates the owner PIN. Do this immediately after deploying and share the owner PIN only with the owner.
- The owner PIN protects changes to the shared Supabase configuration, not edits to spreadsheet cells.

EXPORT
- Export libraries load from public CDNs, so Excel/PDF export requires internet access.

LOCAL PREVIEW
The Netlify Function/Blobs shared settings feature requires Netlify hosting. A plain local static server will not provide shared settings.
