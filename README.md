# ThinkTrail.AI

ThinkTrail.AI is a friendly study companion built to help students learn with understanding instead of just getting quick answers. It combines guided tutoring, practice sessions, quizzes, and a lightweight game so learning feels active, encouraging, and motivating.

## Why this project exists

Many students need more than a final answer. They need structure, guided support, and steady progress. ThinkTrail.AI helps with that by offering:

- step-by-step tutoring with hints before revealing answers
- subject-based learning paths
- practice and quiz modes for reinforcement
- a playful Fraction Quest mini-game to keep momentum going
- progress tracking with XP, profile stats, and account-based learning history

## Features

- Guided study flow with hints and explanations
- Subject selection for focused learning sessions
- Practice mode and quiz mode
- Fraction Quest game for quick engagement
- XP and profile progress tracking
- Email/password sign-up with email verification
- Google, Apple, and Microsoft sign-in via Supabase
- Privacy and terms pages for a complete app experience

## Project structure

```text
.
├── index.html                 # Main app experience for signed-in students
├── config.js                  # Browser-side Supabase configuration
├── privacy.html               # Privacy policy
├── terms.html                 # Terms of service
├── signin/
│   └── index.html             # Sign-in and account creation flow
├── supabase/
│   └── functions/
│       └── tutor/
│           └── index.ts       # Secure Groq-powered tutor function
└── README.md                  # Project overview and setup notes
```

## Getting started

This project is a static HTML, CSS, and JavaScript app, so there is no build step required.

1. Open a terminal in the project folder.
2. Start a simple local web server:

```bash
python -m http.server 8000
```

3. Visit http://localhost:8000 in your browser.
4. Sign in or choose Start a session to begin.

> Opening the app with a file:// URL may cause problems with OAuth redirects and browser security checks.

## Supabase setup

The frontend uses the Supabase JavaScript client and a shared browser configuration in config.js.

Before deployment:

1. Create or select a Supabase project.
2. Enable the authentication providers you want to support.
3. Add your local and production URLs under Supabase Authentication → URL Configuration.
4. Create the profiles table and set up row-level security rules for authenticated users.
5. Make sure your email verification settings match the sign-up flow in signin/index.html.

Keep the anonymous key in the browser only, and never expose a service-role secret in frontend code.

## Groq tutor setup

The AI tutor is powered by the Supabase edge function in supabase/functions/tutor/index.ts. The Groq API key should be stored as a Supabase secret, not in the frontend.

```bash
supabase login
supabase link --project-ref your_project_ref
supabase secrets set GROQ_API_KEY=your_groq_api_key
supabase functions deploy tutor
```

This function uses Groq's llama-3.3-70b-versatile model to answer student questions with context-specific tutoring.

## Deployment with Vercel

After deployment, add your production URL to the Supabase Auth settings:

- Site URL: https://your-project.vercel.app
- Redirect URL: https://your-project.vercel.app/**

Also add any custom domain you use. The OAuth redirect in signin/index.html uses the current deployed origin automatically.

## Legal pages

- [Privacy Policy](privacy.html)
- [Terms of Service](terms.html)

## License

This project does not currently include a license file. If you plan to share or deploy it publicly, you may want to add one that matches your intended usage and distribution rules.

## Contributing

Contributions are welcome if you want to improve the learning experience, add new subjects, fix bugs, or refine the tutor flow. If you are building on this project, keep the app student-friendly, accessible, and focused on learning rather than shortcutting answers.

