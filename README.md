# ThinkTrail.AI

ThinkTrail.AI is a browser-based study companion that helps students understand concepts instead of simply copying answers. It combines a guided tutor, practice and quiz modes, and a lightweight learning game with account-based progress tracking.

## Features

- Step-by-step tutoring with hints before answers
- Subject selection and guided study sessions
- Practice and Quiz modes
- Fraction Quest learning game
- XP and profile progress tracking
- Email/password authentication with email verification
- Google, Apple, and Microsoft sign-in through Supabase
- Privacy Policy and Terms of Service pages

## Project Structure

```text
.
├── index.html          # Main authenticated study experience
├── config.js           # Supabase browser client configuration
├── supabase/
│   └── functions/tutor/ # Secure Groq tutor Edge Function
├── privacy.html        # Privacy Policy
├── terms.html          # Terms of Service
└── signin/
    └── index.html      # Sign-in and account creation
```

## Getting Started

This is a static HTML, CSS, and JavaScript project. No build step or package installation is required.

1. Serve the project directory with a local HTTP server.
2. Open the server URL in a browser.
3. Choose **Start a session** or sign in through the authentication page.

For example, with Python installed:

```bash
python -m http.server 8000
```

Then visit [http://localhost:8000](http://localhost:8000).

Opening `index.html` directly with a `file://` URL may prevent OAuth redirects and other browser security-sensitive features from working correctly.

## Supabase Setup

The frontend uses the Supabase JavaScript client loaded from jsDelivr. `config.js` creates the shared Supabase client using the project URL and public anonymous key.

Before deploying:

1. Create or select a Supabase project.
2. Configure the authentication providers you want to offer.
3. Add the local and production URLs to Supabase Authentication URL configuration.
4. Create the `profiles` table and apply Row Level Security policies for authenticated users. The app reads a user profile and updates the user’s `xp` value.
5. Confirm that email verification settings match the sign-up flow in `signin/index.html`.

The Supabase anonymous key is intended for browser use. Keep database access protected with appropriate Row Level Security policies, and never place a Supabase service-role key in frontend code.

## Groq Tutor Setup

The tutor calls Groq through `supabase/functions/tutor/index.ts`. The Groq API key must be stored as a Supabase secret, not in the frontend:

```bash
supabase secrets set GROQ_API_KEY=your_groq_api_key
supabase functions deploy tutor
```

The function uses Groq's `llama-3.3-70b-versatile` model and receives the student's question, selected subject, and tutor mode. Make sure the Supabase CLI is linked to the project before deploying:

```bash
supabase login
supabase link --project-ref your_project_ref
```

## Deployment with Vercel

This repository is configured as a no-build Vercel static site. Deploy it from the project root with the Vercel CLI:

```bash
npx vercel
```

For a production deployment:

```bash
npx vercel --prod
```

Or import the repository in the Vercel dashboard and leave the framework preset as **Other**. No build command or output directory is required. The included `vercel.json` provides clean routes for `/signin`, `/privacy`, and `/terms`.

After deployment, add the production URL to Supabase Authentication → URL Configuration:

- Site URL: `https://your-project.vercel.app`
- Redirect URL: `https://your-project.vercel.app/**`

Also add any custom domain you use. The OAuth callback in `signin/index.html` automatically uses the current deployed origin.

## Legal Pages

- [Privacy Policy](privacy.html)
- [Terms of Service](terms.html)  
