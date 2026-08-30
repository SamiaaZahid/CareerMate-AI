# **CareerMate AI**

## **Overview**

**CareerMate AI** is a mobile application designed to help students and learners navigate their career journey with ease. From building a professional resume to discovering the right internships and scholarships, CareerMate AI acts as an all-in-one career companion powered by AI.

## **Problem Statement**

Students often struggle to navigate their career paths, building an effective resume, finding relevant internships, identifying scholarship opportunities, and planning the right skills to learn. CareerMate AI addresses this gap by bringing all these tools into a single, easy-to-use platform.

## **Target Users**

Students and Learners looking for guidance on career planning, resume building, and skill development.

## **Core Features**

* **Student Profile** – Create and manage a personal academic/career profile
* **CV Upload** – Upload resume for analysis
* **AI Resume Analysis** – Get AI-driven feedback and suggestions on your resume
* **Internship Recommendations** – Discover internships matched to your profile
* **Scholarship Recommendations** – Find scholarships suited to your background
* **Skill Roadmap** – Get a personalized learning path to build in-demand skills
* **AI Career Chat** – Chat with an AI assistant for career guidance, powered by Google Gemini
* **Admin Panel** – A hidden, admin-only screen for managing internship, scholarship, and skill roadmap listings without touching code (see below)

## **User Journey**

* Student signs up and completes their profile
* Uploads their CV
* AI analyzes the resume and provides feedback
* App suggests relevant internships and scholarships
* Student explores the skill roadmap
* Student uses AI chat for additional guidance

## **Tech Stack**

* **Frontend:** Flutter (Dart)
* **AI:** Google Gemini API (AI Career Chat, Resume Analysis)
* **Database (Live Data):** Supabase (internships, scholarships, skill roadmaps)
* **Local Storage:** SQLite (student accounts, kept separate from admin data)
* **Version Control:** Git & GitHub

## **How the Admin Panel Works**

The app has two sides:

1. **The student side** – where users log in, upload resumes, and view internships/scholarships.
2. **The admin side** – a hidden screen, accessible only to the team, where internships, scholarships, and skill roadmaps can be added, edited, or deleted through a simple form. No coding required.

**Why this was built:** Previously, all internship and scholarship data was stored in static JSON files inside the app's code. Adding or updating a listing meant editing code and pushing it to GitHub, which wasn't practical for teammates less comfortable with that process.

**How it works:**

* Built using **Supabase**, a free cloud database (project name: "MAD Team 4"), acting like an online spreadsheet built for apps.
* Three tables were created: one each for internships, scholarships, and skill roadmaps.
* All existing data was migrated from the old JSON files into these tables.
* The Flutter app now fetches live data from Supabase instead of reading fixed local files, so updates appear for everyone instantly.
* A "Manage Data" screen was added inside Settings, accessible only with a shared admin login (`admin@careermateai.com`). Any team member can log in with this account to add, edit, or delete listings through a form.
* Permission rules (Row Level Security / RLS) ensure anyone can view the data, but only an admin-authenticated user can modify it.
* Admin data is kept completely separate from student accounts, which remain stored locally on each device (SQLite), so personal user data and admin-managed content never mix.

In short: instead of hardcoding opportunities into the app, there is now a live, editable database that any team member can update without opening the code.

## **Future Scope**

* Expanding admin capabilities to include usage analytics and moderation tools.

## **Project Status**

This project is complete as of Week 4. The app now includes a working AI Career Chat (Gemini-powered), real AI-driven resume analysis, a live Supabase-backed database for internships/scholarships/skill roadmaps, an admin management panel, and a working feedback form with validation.

## **Team**

Built collaboratively as part of the Mobile App Development with Flutter Virtual Internship.

## **Getting Started**

\`\`\`bash
flutter pub get
flutter run
\`\`\`

## **Navigation Flow**

* **Step 1:** Login/Signup
* **Step 2:** Home (Dashboard)
* **Step 3:** Profile (with CV Upload)
* **Step 4:** Resume Analysis & Recommendations (AI-powered, live data from Supabase)
* **Step 5:** Skill Roadmap / AI Career Chat
* **Step 6 (Admin only):** Settings → Manage Data → Add/Edit/Delete listings

## **App Screenshots**

Screenshots of the final app showing all core screens, navigation flow, and the admin panel.

### Login Screen
<img width="1453" height="906" alt="Screenshot 2026-08-30 145158" src="https://github.com/user-attachments/assets/72853859-1379-46c0-b3fb-3f6f18a6ffe0" />


### Home / Dashboard

<img width="1288" height="886" alt="Screenshot 2026-08-30 145422" src="https://github.com/user-attachments/assets/7708ef5f-7c22-4ca8-9edf-63b1096ba0c9" />

### Program Listing (Live Data)
<img width="1285" height="842" alt="Screenshot 2026-08-30 145737" src="https://github.com/user-attachments/assets/02295803-38b0-4fa1-8d86-6e59034dcb7d" />


### Program Details
<img width="1275" height="870" alt="Screenshot 2026-08-30 145808" src="https://github.com/user-attachments/assets/613e5f0b-b026-4dce-9b7f-b03e6d5accb8" />


### Feedback Form
<img width="1286" height="852" alt="Screenshot 2026-08-30 145836" src="https://github.com/user-attachments/assets/e1b002b0-f49c-4773-acd2-5d46cea51973" />


### AI Career Chat
<img width="1287" height="847" alt="Screenshot 2026-08-30 145634" src="https://github.com/user-attachments/assets/05229889-062c-42c0-8d5e-70f3c3e50265" />


### Admin – Manage Data

<img width="1267" height="847" alt="Screenshot 2026-08-30 145859" src="https://github.com/user-attachments/assets/758f2ab7-b8ab-44fa-ac9a-55edb59f7169" />
<img width="1281" height="847" alt="Screenshot 2026-08-30 150130" src="https://github.com/user-attachments/assets/4053bed1-983b-42f0-8e9f-c739039fd7a8" />

