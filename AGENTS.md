# Agent Guide for ProjectRails

This file provides essential context for AI coding agents working on this repository. All information below is derived from the actual project files.

---

## Project Overview

This is a **Ruby on Rails 7.1** web application named `ProjectRails`. It implements a simple interactive chat interface that uses the Hugging Face inference API to perform question-answering against a user-provided context. The app has two main screens: a homepage (`HomeController`) and a chat form (`HuggingfaceController`).

- **Ruby version:** 3.3.1 (specified in `.ruby-version` and `Gemfile`)
- **Rails version:** ~> 7.1.3, >= 7.1.3.3
- **Primary language:** English (comments, documentation, UI text)

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| Framework | Ruby on Rails 7.1 |
| Database | SQLite3 (~> 1.4) via Active Record |
| Web server | Puma (>= 5.0) |
| CSS | Tailwind CSS via `tailwindcss-rails` (~> 2.6) |
| JavaScript | ESM import maps (`importmap-rails`), no Node.js bundler |
| Frontend interactivity | Hotwire (Turbo + Stimulus) |
| External AI API | Hugging Face (`hugging-face` gem ~> 0.3.5) |
| Asset pipeline | Sprockets (`sprockets-rails`) |
| Image processing | `libvips` (commented out / available via `image_processing`) |
| Testing | Rails built-in Minitest, Capybara, Selenium WebDriver |

---

## Project Structure

```
app/
  controllers/
    application_controller.rb
    home_controller.rb          # Landing page
    huggingface_controller.rb   # Chat form & submission handler
  helpers/
  models/
    application_record.rb       # No domain models currently defined
  services/
    huggingface_service.rb      # Wraps HuggingFace::InferenceApi calls
  views/
    home/index.html.erb
    huggingface/index.html.erb
    layouts/application.html.erb
  javascript/
    application.js              # Importmap entrypoint
    controllers/                # Stimulus controllers
  assets/
    config/manifest.js
    images/                     # Q-A-Chat-icon.png, favicon.ico
    stylesheets/
      application.tailwind.css
      application.css
config/
  routes.rb
  database.yml                  # SQLite for all environments
  credentials.yml.enc           # Encrypted credentials (Hugging Face API key)
  tailwind.config.js
  importmap.rb
db/
  seeds.rb                      # Empty / placeholder
test/
  controllers/home_controller_test.rb
  system/                       # Empty (configured for Selenium/Chrome)
```

### Controllers & Routes

- `root 'home#index'` — Landing page with a link to the chat.
- `resources :huggingface, only: [:index, :show, :create]` — Chat form (`GET`), show (`GET`), and submission (`POST`).
- `get "up" => "rails/health#show"` — Health-check endpoint (`/up`).

### Service Layer

`HuggingfaceService` lives in `app/services/` and is not a model. It:
1. Accepts `query` (question) and `context` strings.
2. Instantiates `HuggingFace::InferenceApi` with the encrypted API token.
3. Calls `client.question_answering(...)` and returns the `answer` string.
4. Logs initialization, client creation, responses, and errors via `Rails.logger`.

---

## Build and Run Commands

### Install dependencies
```bash
bundle install
```

### Start the development server
```bash
rails server
```
Default port is **3000**.

### Start with Tailwind CSS live reloading
```bash
./bin/dev
```
This uses `foreman` (auto-installed if missing) to run both the Rails server and `bin/rails tailwindcss:watch` via `Procfile.dev`.

### Database setup
The app uses SQLite. There are currently no custom migrations or seed data required for core functionality.
```bash
rails db:prepare
```

### Docker
A multi-stage `Dockerfile` is present:
```bash
docker build -t project-rails .
```
The image runs as a non-root `rails` user, exposes port 3000, and the entrypoint (`bin/docker-entrypoint`) runs `rails db:prepare` before starting the server in production mode.

---

## Testing Instructions

### Run the full test suite
```bash
rails test
```

### System tests
System tests are configured to run with Selenium + Chrome (`driven_by :selenium, using: :chrome`). There are no system tests written yet, but the infrastructure is ready:
```bash
rails test:system
```

### Test configuration
- Tests run in parallel by default using `parallelize(workers: :number_of_processors)`.
- Fixtures are loaded from `test/fixtures/*.yml` automatically (`fixtures :all`).
- There are currently no fixture files other than the empty `files/` directory.

### Existing tests
- `test/controllers/home_controller_test.rb` — asserts that `GET home_index_url` returns a success response.

---

## Code Style & Conventions

- **Indentation:** 2 spaces (standard Rails).
- **String literals:** Mixed single and double quotes; the existing codebase uses double quotes in most Ruby files and ERB templates.
- **ERB templates:** Use standard Rails helpers (`form_with`, `link_to`, `image_tag`, etc.) with Tailwind utility classes directly in HTML/ERB.
- **Controllers:** Use `flash` to pass simple result messages between actions (e.g., `HuggingfaceController#create` redirects to `huggingface_index_path` with `flash[:result]`).
- **Logging:** The project makes heavy use of `Rails.logger.info` and `Rails.logger.error` for tracing service-layer behavior.
- **Services:** Custom business logic is placed in `app/services/` (e.g., `HuggingfaceService`).

---

## Security Considerations

- **Encrypted credentials:** The Hugging Face API key is stored in `config/credentials.yml.enc` under the key `huggingface_api_key`. It is accessed as:
  ```ruby
  Rails.application.credentials.huggingface_api_key
  ```
  The `config/master.key` file is **gitignored** and must never be committed.
- **CSRF protection:** Enabled by default (`ApplicationController < ActionController::Base`).
- **Force SSL:** Enabled in production (`config.force_ssl = true`).
- **CSP:** A content security policy initializer exists (`config/initializers/content_security_policy.rb`) but is currently not configured/enforced.
- **No authentication:** The application does not currently implement user authentication or authorization.
- **Parameters:** The `HuggingfaceController` reads raw `params[:query]` and `params[:context]` without strong parameters. If the scope expands, consider introducing `ActionController::Parameters` permit lists.

---

## Deployment

### Render (configured but incomplete)
`render.yaml` defines a Ruby web service named `question-answering-chat` with:
- Runtime: Ruby (free plan)
- Build command: `./bin/render-build.sh` *(this script does **not** currently exist in the repo)*
- Start command: `bundle exec rails server`
- Required env vars: `DATABASE_URL`, `RAILS_MASTER_KEY`, `WEB_CONCURRENCY`

### Docker (production-ready)
The `Dockerfile` builds a production image in three stages:
1. **base** — Ruby 3.3.1-slim with bundler configured for deployment.
2. **build** — installs build tools, gems, copies code, precompiles Bootsnap and assets.
3. **final** — copies artifacts, installs runtime deps (`libsqlite3-0`, `libvips`, `curl`), runs as `rails` user.

---

## Asset Pipeline & Tailwind CSS

- Tailwind CSS is compiled via the `tailwindcss-rails` gem, not a Node.js toolchain.
- Configuration: `config/tailwind.config.js`
- Input CSS: `app/assets/stylesheets/application.tailwind.css`
- Build output: `app/assets/builds/` (gitignored except `.keep`)
- Sprockets manifest: `app/assets/config/manifest.js`
- JavaScript is loaded via importmap (`config/importmap.rb`); no Webpack, Vite, or esbuild is involved.

---

## External Dependencies & API

- **Hugging Face Inference API:** The app calls `question_answering` using the `alchaplinsky/hugging-face` Ruby gem.
- **Redis:** Configured for Action Cable in production (`config/cable.yml`), but the `redis` gem is not included in the `Gemfile` (commented out). If Action Cable is enabled later, uncomment the gem and ensure `REDIS_URL` is set.

---

## Notes for Agents

- **No database migrations are required** for the current chat feature. The app does not persist chats, contexts, or users.
- If adding new Stimulus controllers, place them in `app/javascript/controllers/` and they will be auto-loaded via `eagerLoadControllersFrom` in `app/javascript/controllers/index.js`.
- When modifying Tailwind classes, run `./bin/dev` to see changes reflected immediately.
- If the `render-build.sh` script is needed for Render deployment, create it in `bin/` and ensure it is executable (`chmod +x`).
