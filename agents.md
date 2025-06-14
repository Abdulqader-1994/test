# Project Overview
Ailence (Artificial Intelligence Learning Ecosystem, New Creative Edge) is a multifaceted platform built around five key pillars:
1. AI-driven learning for schools and universities.
2. An earning system that rewards contributors with shares.
3. A trading platform for buying and selling those shares.
4. Social media features.
5. A suite of mind games.


This repository contains four main components used to build Ailence's platform.

## 1. `app`
A Flutter application targeting all major platforms. This folder holds the protected pages available to authenticated users. It depends on packages such as `graphql_flutter`, `get`, and various UI libraries. Build the application using the standard Flutter tooling (`flutter run` for development, `flutter build` for release). Platform-specific directories were removed from this repository but can be regenerated with `flutter create .`.

#### The `lib` directory contains:
- `main.dart` – the application entry point.
- `main/` which organizes core features:
  - `component/` folder: whcih consist of:
    - `main_widget.dart file`: has MainWidget which is the parent widget for all main pages and it's contains AppBar and drawer
    - `page_header.dart file`: has a shared widget for main pages header
    - `table_cell.dart file`: has table cell widget that used in almost all tables in the project
  - `model/` : whcih consist of:
    - `api.dart file`: the api handler for requests to graphql server
    - `auth.dart file`: the authentication handler for user
    - `shares_trade.dart file`: the shares trade handler
    - `shares.dart file`: the user share details
    - `studydata.dart file`: the materiales that student subscribed
    - `user.dart file`: the user info details
    - `workdata.dart file`: the user work details
  - `pages/` for screens:
    - `auth/` whcih consist of:
      - `login_background.dart file`: the parent widget for auth pages wich has animated background
      - `login_data.dart file`: setting username and country for user (after he created un account)
      - `login.dart file`: the user login page
      - `loign_redirect.dart file`: the redirect route which used for web social login
      - `restore.dart file`: the restore page for user that submit a request to change your password and after that he got un email in his inbox
      - `verify_email.dart file`: which used to verify user email via submitting the code from his inbox
      - `verify_password.dart file`: for adding a new password
    - `work\`: which has all task for user to provide and verify study materials and it consist of:
      - `entidio/` it's platform for work flow tasks, used to add and verify study content, which consist of:
        - `component/`: has main widgets for working:
          - `bottom_bar.dart file`: this widget has bottom sheet that contain all buttons for edit or add contents
          - `lesson_header.dart file`: this widget is a header for page that provide some details and rtl buttons and view mode buttons
          - `painter.dart file`: this widget used for free drawing and inserting the result for content
          - `part_editor.dart file`: this widget that display every part with it's custom paint lines
          - `question.dart file`: used to view questions
          - `rich_text_editor.dart file`: the widget to view part text
        - `model/`: contain all models for entdio:
          - `edit_note.dart file`: edit note request from a user to change existed content
          - `lesson.dart file`: lesson model
          - `mao.dart file`: lesson map
          - `part.dart file`: part model that contain content and it's styles
          - `question.dart file`: question model
        - `util/`: contain serverl functions used for entidio project:
          - `format_duration.dart file`:  change Duration to to string '$minutes:$seconds'
          - `get_random_color.dart file`: get random color from a list
          - `line_painter.dart file`: draw the line connecter in `part_editor` widget
          - `picker.dart file`: picker class to pick color or pick image
          - `quill_image_block.dart file`: the custom image block in quill
          - `quill_math_block.dart file`: the custom math block in quill
          - `set_time_format.dart file`: return string return '$minutes:$secounds' from int ms value
          - `show_error.dart file`: show error massage
        - `controller.dart`: getx entidio controller that has a lot of functions for mainpulate content
        - `view.dart`: entry point for entidio app
      - `balance.dart file`: show user balance and some info
      - `index.dart file`: the work page entry point that has three sub pages: `balance` and `work` and `trade`
      - `material.dart file`: display all materials that still has tasks (for adding or verify it's content)
      - `task.dart file`:  display info for all material tasks
      - `trade.dart file`: trade shares
      - `work.dart file`: display work info
    - `account.dart file`: display user account info
    - `faq.dart file`: display faq
    - `games.dart file`: the mind game page (but it didn't has any game)
    - `social.dart file`: the social page (but it's still under construction)
    - `store.dart file`: the store to buy materials
    - `study.dart file`: the study page 
  - `utils/`: has some functions:
    - `app_vars.dart file`: the app color and width and others
    - `btn_style.dart`: contains shared Button style
    - `util.dart file`: Utility class for formatDuration and setTimeFormat and getRandomColor and generate id ..etc
  - `main_controller.dart` providing global state.
Assets such as fonts and images live under `assets/`.


## 2. `frontend`
##### it's the project website homepage
Public website built with Vue 3 and Tailwind CSS. It exposes marketing pages and other unauthenticated content for `ailence.ai` and `ailence.com`. Use `yarn` to install dependencies and `yarn dev` to start the development server. Production bundles are created with `yarn build`.
The `src` folder is organized as follows:
- `components/` with reusable UI elements such as `headerNav.vue`, `appFooter.vue`, and `calculator.vue`.
- `views/` provides pages like `HomeView.vue`, `terms.vue`, and `privacy.vue`.
- `utils/` contains the Vue router (`router.js`) and translation helpers (`translation.js`).
- `assets/` holds static images.
Entry files `App.vue` and `main.js` bootstrap the app.


## 3. `backend`
Serverless backend running on Cloudflare Workers. It exposes a GraphQL API defined under `src/graphql`. Durable objects (see `src/durable`) handle trade and task functionality. Databases are configured in `wrangler.toml` using Cloudflare D1. Tests are defined under `test` and run via `npm test` (Vitest). Secrets like `MAILTRAP_TOKEN` and Google OAuth credentials must be added with `wrangler secret put <NAME>` for production or configured in `[vars]` for local development.

Key directories under `src` include:
- `graphql/` with the schema builder and resolvers (`builder.ts`, `query.ts`, `mutate.ts`).
- `durable/` providing durable objects `trade.ts` and `task.ts`.
- `libs/` containing business logic modules (`admin.ts`, `auth.ts`, `shares.ts`, `study.ts`, `user.ts`, `work.ts`).
- `utils/` for common helpers like `check_auth.ts` and `error.ts`.
- `db/` with SQL files that define D1 tables.
The entry point `index.ts` configures the GraphQL server, and tests live in the `test/` folder.

## 4. `panal`
Admin panel powered by Quasar and Vue. It includes pages for user and task management. Install dependencies with `yarn`, then launch with `yarn dev`. Quasar's configuration lives in `quasar.config.js`.
The Quasar `src` directory contains:
- `pages/` such as `user.vue`, `task.vue`, and `curriculum.vue` for managing app data.
- `layouts/` with the main layout (`MainLayout.vue`).
- `router/` defining client routes.
- `boot/` for initialization scripts (`apollo.js` and `google.js`).
- `apollo/` where the GraphQL client is configured.
Static assets reside in `public/`, and configuration is handled by `quasar.config.js`.


## Development Tips
- Node 18+ is required for `frontend`, `backend`, and `panal`.
- Flutter 3.6+ is required for the `app` folder.
- Run `npm install` in each Node-based folder before running scripts.
- Tests in `backend` use Cloudflare's Worker environment and may require additional setup.

---
This file provides context for developers unfamiliar with the project structure.
