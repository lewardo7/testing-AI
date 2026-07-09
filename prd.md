Tentu. Karena saya mengikuti percakapan kita dari awal, saya tahu tujuan Anda adalah membuat **aplikasi Clinic Pathway** yang modern menggunakan **React + TypeScript + Vite + Tailwind + Supabase**, dan Anda akan menggunakan **Codex** sebagai AI coding assistant.

Saya menyarankan kita membuat PRD (Product Requirements Document) terlebih dahulu. Ini juga yang biasa dilakukan di perusahaan sebelum mulai coding.

---

# Product Requirements Document (PRD)

## Project Name

**Clinic Pathway Management System (CPMS)**

Version: 1.0

Status: Draft

Owner: Anda

Tech Stack:

* React
* TypeScript
* Vite
* Tailwind CSS
* Supabase
* Git
* Codex (AI Coding Assistant)

---

# 1. Background

Saat ini pengelolaan Clinic Pathway masih dilakukan secara manual atau menggunakan sistem yang belum terintegrasi.

Dokumen sulit dicari.

Approval lama.

Versi dokumen tidak jelas.

Sulit mengetahui status implementasi setiap Clinic Pathway.

Aplikasi ini bertujuan menjadi pusat pengelolaan seluruh siklus hidup Clinic Pathway.

---

# 2. Goal

Membangun aplikasi web yang mampu mengelola seluruh proses Clinic Pathway mulai dari pembuatan hingga implementasi.

Target pengguna:

* Dokter
* Komite Medis
* Admin
* Reviewer
* Approval
* Manajemen Rumah Sakit

---

# 3. User Roles

## Administrator

Hak akses:

* Mengelola user
* Mengelola role
* Mengelola master data
* Approval akhir
* Melihat seluruh data

---

## Author

Hak akses:

* Membuat Clinic Pathway
* Mengedit draft
* Mengirim approval

---

## Reviewer

Hak akses:

* Review dokumen
* Memberikan komentar
* Approve / Reject

---

## Approver

Hak akses:

* Approval final

---

## Viewer

Hak akses:

* Hanya melihat CP yang sudah aktif

---

# 4. Main Modules

## Dashboard

Berisi:

* Total CP
* Active CP
* Draft CP
* Expired CP
* Pending Approval
* Recently Updated
* Notification
* Quick Action

---

## Library

Berisi seluruh Clinic Pathway.

Fitur:

* Search
* Filter
* Sort
* Download PDF
* Preview
* Version History

---

## Clinic Pathway

Submenu:

* Draft
* Active
* Implemented
* Archived

---

## Authoring

Digunakan untuk membuat CP.

Fitur:

* Rich Text Editor
* Diagnosis
* ICD
* Procedure
* Medication
* Lab
* Radiology
* Reference
* Attachment

---

## Approval

Workflow:

Draft

-> Reviewer

-> Revision

-> Reviewer

-> Approval

-> Published

---

## Financial Intelligence

Menampilkan:

* Cost Analysis
* Average Cost
* LOS
* Revenue
* Efficiency

---

## Claim Explorer

Menampilkan:

* Claim Data
* BPJS
* INA-CBG
* Claim Detail
* Filter

---

## Report

Laporan:

* Active CP
* Approval History
* Revision History
* User Activity

---

## Settings

* User
* Role
* Permission
* Hospital Profile
* Notification

---

# 5. Dashboard

Widget:

* Total Clinic Pathway
* Active
* Draft
* Pending Approval
* Expired
* Recently Updated

Charts:

* Monthly Created
* Approval Trend
* Status Distribution

Quick Menu:

* Create CP
* Library
* Approval
* Reports

---

# 6. Functional Requirement

### Login

* Username
* Password
* Remember Me
* Forgot Password

---

### Authentication

* JWT
* Role Based Access

---

### User Management

CRUD User

CRUD Role

Assign Permission

---

### Clinic Pathway

Create

Read

Update

Delete

Archive

Restore

Versioning

Approval

Comment

History

---

### Search

Search seluruh CP

Filter berdasarkan:

* Diagnosis
* Department
* Status
* Author
* Version

---

### Notification

Approval

Rejected

Comment

Published

Expired

---

# 7. Non Functional Requirement

Performance

* Load Dashboard < 3 detik

Security

* Authentication
* Authorization
* Audit Log

Availability

* 99%

Responsive

* Desktop
* Tablet

---

# 8. Database (High Level)

User

Role

Permission

Clinic Pathway

Diagnosis

Procedure

Medication

Attachment

Approval

Comment

Revision

Notification

Audit Log

---

# 9. UI Style

Tema:

Modern

Minimalis

Medical

Professional

Color:

* White
* Blue
* Gray

Framework:

Tailwind CSS

Icons:

Lucide React

---

# 10. MVP (Versi Pertama)

Target pertama yang akan kita selesaikan:

[x] Login

[x] Dashboard

[x] Sidebar

[x] Library

[x] Detail Clinic Pathway

[x] Authoring

[x] Approval

Belum termasuk:

* Financial Intelligence
* Claim Explorer
* Reporting lanjutan

---

# 11. Future Features

* AI Recommendation
* AI Summary
* AI Medical Review
* AI ICD Suggestion
* BPJS Integration
* HIS Integration
* Export Word
* Export PDF
* Analytics
* Mobile App

---

# Roadmap Development

## Sprint 1

* Setup Project
* Login
* Layout
* Sidebar
* Dashboard

---

## Sprint 2

* Library
* Detail CP
* Search
* Filter

---

## Sprint 3

* Authoring
* Versioning
* Draft

---

## Sprint 4

* Approval Workflow
* Notification
* History

---

## Sprint 5

* Financial Intelligence
* Claim Explorer
* Report

---
