HabotConnect LSA Verification & Data Lineage Integration

A Flutter mobile application implementing the LSA Onboarding Gate for the HabotConnect hiring project. The project demonstrates stateless Flutter presentation, modular "Byt" components, secure API submission, data lineage validation, fail-closed behavior, data quarantine, and UI friction tracking.

Project Overview

The application implements the LSA Verification & Data Lineage Integration scenario with:

Stateless Flutter UI with atomic "Byt" component boundaries

LSA onboarding verification form based on the provided UI specification

API submission logic with an independent validation/security pipeline

Mandatory metadata headers: x-trace-id and x-logic-hash

Data lineage validation through predecessor_id

Fail-closed security that stops execution when required compliance conditions fail

Data quarantine for rejected submissions and compliance failures

UI friction tracking when parent_consent_code receives no typing/submission activity for more than 5 seconds

Three demonstrable test scenarios required by the candidate attachment

Requirements Mapping

Requirement

Implementation

LsaVerificationScreen

Stateless Flutter presentation screen

Header

LSA Onboarding Gate + HabotConnect Data Compliance

lsa_id

Prefilled with LSA-7049

parent_consent_code

User-editable input

predecessor_id

System-provided, read-only value

Action

Verify & Submit

Status states

Idle, Processing, Success, Quarantined (Fail-Closed)

Stateless UI

Presentation screen receives state through inputs

Modular "Byt" components

Small, focused UI components

API submission

Dedicated submission/orchestration layer

x-trace-id

UUID generated per submission

x-logic-hash

SHA-256 metadata generated for the request

predecessor_id validation

Lineage validation before network submission

Fail-closed behavior

Submission stops immediately on required compliance failures

Data quarantine

Rejected data is isolated through the quarantine service

Friction tracking

parent_consent_code inactivity detection over 5 seconds

UI Specification

The primary screen is:

LsaVerificationScreen

Header

Title: LSA Onboarding Gate

Subtitle: HabotConnect Data Compliance

Form Fields

Field

Behavior

Default/System Value

lsa_id

Text input, prefilled

LSA-7049

parent_consent_code

User-editable text input

User enters code

predecessor_id

Hidden/read-only system state

PRED-9982-XYZ

The predecessor_id is intentionally not editable by the user because it represents system-controlled lineage information.

Action

Verify & Submit

Status Indicator

The screen displays the current system state:

Idle

Processing

Success

Quarantined (Fail-Closed)

Architecture

The application separates presentation, orchestration, validation, security, and networking concerns.

┌──────────────────────────────────────────────┐
│                Presentation                  │
│                                              │
│  LsaVerificationScreen (StatelessWidget)     │
│             │                                │
│             ├── ComplianceHeaderByt          │
│             ├── StatusBannerByt              │
│             ├── LsaIdFieldByt                │
│             ├── ParentConsentFieldByt        │
│             ├── PredecessorIdFieldByt        │
│             └── VerifySubmitButtonByt        │
└──────────────────────┬───────────────────────┘
                       ↓
┌──────────────────────────────────────────────┐
│              Submission / Domain             │
│                                              │
│  SubmissionController / Coordinator          │
│  - validates submission                      │
│  - validates lineage                         │
│  - generates metadata                        │
│  - handles fail-closed outcomes              │
└──────────────────────┬───────────────────────┘
                       ↓
┌──────────────────────────────────────────────┐
│               Core Services                  │
│                                              │
│  Validation    Security    Crypto    Friction│
│  Lineage      Quarantine   UUID      Tracker │
│  Compliance              SHA-256             │
└──────────────────────┬───────────────────────┘
                       ↓
┌──────────────────────────────────────────────┐
│                 Network                     │
│                                              │
│  Compliance Verification API                 │
│  Mock implementation for demonstration       │
└──────────────────────────────────────────────┘

Stateless Presentation

LsaVerificationScreen is implemented as a StatelessWidget.

The presentation layer is responsible for rendering the current state and composing the Byt components. Submission orchestration, validation, security decisions, and friction-tracking lifecycle remain outside the stateless presentation widget.

Byt Component Architecture

The UI is composed of focused, reusable Byt components:

Component

Responsibility

ComplianceHeaderByt

Displays the LSA onboarding title and compliance subtitle

StatusBannerByt

Displays Idle, Processing, Success, and Quarantined states

LsaIdFieldByt

Displays the prefilled LSA ID

ParentConsentFieldByt

Handles parent_consent_code input

PredecessorIdFieldByt

Displays the system-controlled read-only lineage ID

VerifySubmitButtonByt

Provides the primary verification action

Each component has a focused responsibility, receives explicit inputs, and avoids unnecessary internal state.

API Integration

Endpoint

POST https://api.habotconnect.com/v1/compliance/verify

Required Headers

Every valid outbound submission includes:

Content-Type: application/json
x-trace-id: <generated UUID>
x-logic-hash: <generated SHA-256 value>

Request Body

The expected request structure is:

{
  "predecessor_id": "PRED-9982-XYZ",
  "lsa_id": "LSA-7049",
  "parent_consent_code": "PCC-2026-9901",
  "timestamp_utc": "2026-08-07T11:30:00Z"
}

For an actual submission, timestamp_utc is generated from the current UTC time.

x-trace-id

A unique request identifier generated for each submission.

x-logic-hash

A SHA-256 metadata value generated from the canonical request representation used by the implementation.

Security & Fail-Closed Behavior

Data Lineage

predecessor_id represents the required lineage relationship.

Before any network request is made:

The system checks that predecessor_id exists.

The lineage validator rejects null or empty lineage.

A missing lineage condition raises a lineage validation failure.

The network request is blocked.

The submission is quarantined.

The UI enters Quarantined (Fail-Closed).

The user cannot edit the normal predecessor_id value because it is system-controlled.

Validation Boundary

UI validation provides user feedback, but it is not the security boundary.

The submission layer independently validates the data before making the API request:

User taps Verify & Submit
        ↓
Submission validation
        ↓
Lineage validation
        ↓
Fail-closed security gate
        ↓
Metadata generation
        ↓
API request

No API request is made when a required security/compliance condition fails.

Data Quarantine

Rejected submissions are isolated through the quarantine service.

For the hiring-project demonstration, quarantine is implemented in memory. The implementation avoids sending rejected data to the compliance API.

UI Friction Tracking

The application specifically tracks hesitation on the parent_consent_code field.

Rule

If the user:

focuses parent_consent_code, and

does not type or submit

for more than 5 seconds, a friction event is generated.

Example:

[UI_FRICTION_LOG]
Timestamp: 2026-08-07T11:31:05Z
Field: parent_consent_code
Hesitation Duration: 5.2s

The timer/tracking lifecycle is kept outside the stateless presentation widget.

Required Test Scenarios

Case 1: Valid Submission

Input

lsa_id = LSA-7049
parent_consent_code = PCC-2026-9901
predecessor_id = PRED-9982-XYZ

Expected Behavior

Idle
  ↓
Verify & Submit
  ↓
Processing
  ↓
Validation passes
  ↓
x-trace-id + x-logic-hash generated
  ↓
API request sent
  ↓
Success

The UI displays:

Success

Demo

Use the default valid system-provided lineage ID and enter:

PCC-2026-9901

Then tap Verify & Submit.

Case 2: Missing Lineage / Orphan Data

Condition

The system-provided predecessor_id is null or empty.

The user does not edit the predecessor field. The missing-lineage condition is simulated through the application's mock/test state.

Expected Behavior

Verify & Submit
        ↓
Lineage validation fails
        ↓
LineageException / validation failure
        ↓
API request is NOT sent
        ↓
Data quarantined
        ↓
Quarantined (Fail-Closed)

Demo

Run the missing-lineage mock/test state so that:

predecessor_id = null

Then attempt the submission.

Case 3: Null API Response / Timeout

Condition

The mock API returns either:

HTTP 500

or:

{
  "status": null
}

Expected Behavior

The application fails closed:

API failure is treated as a compliance failure

volatile submission data is purged

form state is reset

submission is locked

UI displays:

Data Quarantined – Compliance Failure

and the status becomes:

Quarantined (Fail-Closed)

Demo

Use the mock API failure/timeout scenario and submit a valid form.

Running the Project

Prerequisites

Flutter SDK compatible with the project's configured Dart SDK

Dart SDK compatible with the project's Flutter version

Setup

flutter pub get

Run

flutter run

Build

flutter build apk --debug

For a release build:

flutter build apk --release

Testing

Run All Tests

flutter test

Static Analysis

flutter analyze

Test Areas

The test suite covers the implemented behavior, including:

cryptographic utilities

UUID/metadata generation

field validation

lineage validation

fail-closed submission behavior

quarantine behavior

friction tracking

submission/integration flows

Note: The exact test count should reflect the latest flutter test result. Update the number below only after running the current test suite.

Test count: <UPDATE WITH CURRENT RESULT>

Project Structure

lib/
├── core/
│   ├── crypto/
│   │   ├── uuid_generator.dart
│   │   └── sha256_generator.dart
│   ├── network/
│   │   └── compliance_verification_api.dart
│   ├── security/
│   │   └── security services
│   ├── validation/
│   │   ├── validation_result.dart
│   │   ├── field_validator.dart
│   │   ├── lineage_validator.dart
│   │   └── compliance_validator.dart
│   ├── quarantine/
│   │   └── quarantine_service.dart
│   └── friction/
│       ├── friction_event.dart
│       └── friction_tracker.dart
│
├── features/
│   └── lsa_verification/
│       ├── data/
│       ├── domain/
│       │   ├── models.dart
│       │   ├── errors.dart
│       │   └── submission_controller.dart
│       └── presentation/
│           ├── lsa_verification_screen.dart
│           └── byts/
│               ├── compliance_header_byt.dart
│               ├── status_banner_byt.dart
│               ├── lsa_id_field_byt.dart
│               ├── parent_consent_field_byt.dart
│               ├── predecessor_id_field_byt.dart
│               └── verify_submit_button_byt.dart
│
└── main.dart

Adjust the paths above if the final repository uses different filenames. The README should always reflect the actual repository structure.

Design Decisions & Assumptions

The candidate attachment specifies the required UI, payload, metadata, lineage behavior, and three test scenarios. Where implementation details are not explicitly specified, the project uses the following choices:

x-trace-id is generated as a unique UUID for each submission.

x-logic-hash is generated as SHA-256 metadata from the implementation's canonical request representation.

predecessor_id is treated as system-controlled/read-only state in the UI.

Missing lineage is rejected before the network request.

Quarantine storage is in memory for this demonstration.

API implementation is mocked for deterministic demonstration of success and failure scenarios.

Friction tracking is specifically attached to parent_consent_code and triggers after more than 5 seconds of inactivity.

API failure is treated as a fail-closed compliance failure, with volatile submission data cleared and further submission locked.

Verification

Before submission, verify:

flutter analyze
flutter test
flutter build apk --debug

Manual Verification

Valid submission → valid consent code + valid lineage → Success

Missing lineage → system lineage is null/empty → no API call + Quarantined (Fail-Closed)

API failure → mock 500/null response → purge/reset/lock + Data Quarantined – Compliance Failure

Friction → focus parent_consent_code, wait >5 seconds without typing/submitting → friction log generated

Hiring Project Submission

This repository is a demonstration project prepared for the HabotConnect Flutter Mobile App Developer hiring process.

The accompanying presentation documents the architecture, security decisions, test scenarios, and UI implementation. The presentation also contains the required 2–3 minute screen-recording demonstration.

License

This repository is a hiring-project demonstration for HabotConnect.