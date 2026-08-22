# **CareerMate AI**

## **Overview**

**CareerMate AI** is a mobile application designed to help students and learners navigate their career journey with ease. From building a professional resume to discovering the right internships and scholarships, CareerMate AI acts as an all-in-one career companion powered by AI.

## **Problem Statement**

Students often struggle to navigate their career paths — building an effective resume, finding relevant internships, identifying scholarship opportunities, and planning the right skills to learn. CareerMate AI addresses this gap by bringing all these tools into a single, easy-to-use platform.

## **Target Users**

Students and Learners looking for guidance on career planning, resume building, and skill development.

## **Core Features**

* **Student Profile** – Create and manage a personal academic/career profile
* **CV Upload** – Upload resume for analysis
* **AI Resume Analysis** – Get AI-driven feedback and suggestions on your resume
* **Internship Recommendations** – Discover internships matched to your profile
* **Scholarship Recommendations** – Find scholarships suited to your background
* **Skill Roadmap** – Get a personalized learning path to build in-demand skills
* **AI Career Chat** – Chat with an AI assistant for career guidance

## **User Journey**

* Student signs up and completes their profile
* Uploads their CV
* AI analyzes the resume and provides feedback
* App suggests relevant internships and scholarships
* Student explores the skill roadmap
* Student uses AI chat for additional guidance

## **Tech Stack**

* **Frontend:** Flutter (Dart)
* **Data:** JSON (local sample data for internships/scholarships)
* **Version Control:** Git & GitHub

## **Future Scope**

* **Admin Panel** – A backend interface to manage and update internship listings, scholarship data, and monitor platform usage. Since internship/scholarship recommendations rely on underlying data, an admin panel will be required in a later phase to keep this data current without hardcoding it into the app.
* **Live AI Integration** – Connecting the AI Resume Analysis and AI Career Chat features to a real AI API.

## **Project Status**

This project has progressed to Week 3. The app now pulls internship and scholarship data from a local JSON file instead of hardcoded text, and includes a working feedback form with input validation.

## **What's New This Week (Week 3)**

* **JSON Data Integration** – Program Listing and Program Details screens now fetch data from a local JSON file (`lib/data/internships.json`) instead of hardcoded lists.
* **Feedback Form** – Added a working feedback form with input validation (empty field checks, email format validation).
* **Loading State** – Added a loading indicator while JSON data is being fetched, for a smoother user experience.

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
* **Step 4:** Resume Analysis & Recommendations (now JSON-powered)
* **Step 5:** Skill Roadmap / AI Chat

## **App Screenshots**

Screenshots of the working prototype showing the four core screens and navigation flow.

### Login Screen

<img width="568" height="909" alt="Screenshot 2026-08-17 004123" src="https://github.com/user-attachments/assets/a718b789-c94f-47e5-8b69-492dcf942b8a" />

<img width="619" height="904" alt="Screenshot 2026-08-17 004133" src="https://github.com/user-attachments/assets/70582874-09f6-4414-8494-d54db81a3301" />


### Home / Dashboard

<img width="609" height="937" alt="Screenshot 2026-08-17 003645" src="https://github.com/user-attachments/assets/56a78b57-283f-449b-8312-c27344654011" />


### Program Listing

<img width="619" height="911" alt="Screenshot 2026-08-17 003720" src="https://github.com/user-attachments/assets/93fbd0e6-38f8-449d-a07c-a4395db3e967" />


### Program Details

<img width="572" height="932" alt="Screenshot 2026-08-17 003733" src="https://github.com/user-attachments/assets/ff5fd2e4-ff4a-4aa2-9e7c-abfb95d25f4f" />

### Feedback Form
<img width="1366" height="768" alt="Screenshot (380)" src="https://github.com/user-attachments/assets/9fba5bda-f5f5-4df2-bcd9-805a989227e9" />


