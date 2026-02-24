# AI Architecture Diagram to Terraform Generator

This project leverages Google's Gemini AI to transform cloud architecture diagrams into executable Terraform Infrastructure as Code (IaC). It provides a web interface to upload diagrams, generate Terraform code, edit the generated code with natural language instructions, and lint the Terraform for best practices and errors.

## Table of Contents

-   [Features](#features)
-   [Technologies Used](#technologies-used)
-   [Prerequisites](#prerequisites)
-   [Installation](#installation)
    -   [Clone the Repository](#clone-the-repository)
    -   [Install Node.js Dependencies](#install-nodejs-dependencies)
    -   [Set Up Environment Variables](#set-up-environment-variables)
    -   [Install TFLint](#install-tflint)
-   [Running the Application](#running-the-application)
-   [Usage](#usage)
    -   [Generate Terraform from a Diagram](#generate-terraform-from-a-diagram)
    -   [Edit Generated Terraform Code](#edit-generated-terraform-code)
    -   [Run Terraform Lint](#run-terraform-lint)

-   [Project Structure](#project-structure)
-   [Contributing](#contributing)
-   [License](#license)

## Features

*   **Diagram to Terraform:** Upload cloud architecture diagrams (e.g., PNG images) to generate initial Terraform AWS configurations.
*   **AI-Powered Code Editing:** Modify the generated Terraform code using natural language instructions (e.g., "Add an S3 bucket with public access logging").
*   **Terraform Linting:** Automatically lint the generated or edited Terraform code using `tflint` to check for style violations, errors, and best practices.
*   **Interactive Web UI:** A simple frontend allows for easy interaction with the backend services.

## Technologies Used

*   **Backend:** Node.js, Express.js
*   **AI Models:** Google Generative AI (Gemini 2.5 Flash for image analysis and code generation/editing)
*   **File Uploads:** Multer
*   **Infrastructure as Code:** Terraform (AWS provider)
*   **Linting:** TFLint
*   **Environment Variables:** `dotenv`
*   **Frontend:** HTML, CSS, JavaScript

## Prerequisites

Before you begin, ensure you have the following installed:

*   **Node.js & npm/yarn:** [Download & Install Node.js](https://nodejs.org/) (includes npm).
*   **Google Gemini API Key:** You'll need an API key from Google AI Studio.
*   **TFLint:** `tflint` must be installed globally or accessible in your system's PATH. See [Install TFLint](#install-tflint) below.

## Installation

### Clone the Repository

```bash
git clone https://github.com/your-username/ai-arch-iac-tool.git
cd ai-arch-iac-tool
```

### Install Node.js Dependencies

```bash
npm install
# or if you use yarn
# yarn install
```

### Set Up Environment Variables

Create a `.env` file in the root of your project directory (e.g., `ai-arch-iac-tool/.env`) with your Google Gemini API key and desired port:

```dotenv
GEMINI_API_KEY=YOUR_GOOGLE_GEMINI_API_KEY
PORT=3001
```

Replace `YOUR_GOOGLE_GEMINI_API_KEY` with your actual key.

### Install TFLint

`tflint` is used for linting the generated Terraform code. It needs to be installed on your system.

**For Windows (Recommended: Chocolatey)**

1.  **Install Chocolatey** (if you don't have it): Open PowerShell **as Administrator** and run:
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    ```
    Close and reopen PowerShell.
2.  **Install TFLint:**
    ```powershell
    choco install tflint
    ```

**For macOS (Recommended: Homebrew)**

```bash
brew install tflint
```

**For Linux (Recommended: ASDF or manual)**

Refer to the [TFLint Installation Guide](https://github.com/terraform-linters/tflint#installation) for your specific distribution or use a tool like ASDF.

**Verify Installation:**

Open a new terminal and run:
```bash
tflint --version
```
You should see the installed TFLint version.

## Running the Application

After installation and setup, you can start the Node.js server:

```bash
npm start
# or
node src/app.js
```

The server will start, and you'll see a message like: `🚀 Server running at http://localhost:3001` (or your specified PORT).

## Usage

Open your web browser and navigate to the address provided in the console (e.g., `http://localhost:3001`).

### Generate Terraform from a Diagram

1.  **Upload:** Click "Choose File" and select an IT/cloud architecture diagram image (e.g., a PNG showing AWS components).
2.  **Generate:** Click the "Generate Terraform" button.
3.  The application will send the image to Gemini, which will parse the diagram into a structured JSON and then generate AWS Terraform code. The generated code will be displayed on the page.

### Edit Generated Terraform Code

After Terraform code is generated, a "Edit Code" button will appear.

1.  **Click "Edit Code"**: A prompt will appear.
2.  **Enter Instruction:** Type a natural language instruction for how you want to modify the code (e.g., "Add an S3 bucket named my-app-logs with public read access," or "Change the EC2 instance type to t3.medium").
3.  The Gemini editor agent will attempt to apply your instruction to the `lastGeneratedCode` and display the updated Terraform.

### Run Terraform Lint

After Terraform code is generated, a "Run Terraform Lint" button will appear.

1.  **Click "Run Terraform Lint"**: The application will execute `tflint` against the currently generated Terraform code.
2.  The linting results will be displayed on the page. If no issues are found, a success message will appear. If issues or errors are detected, they will be listed.

## Project Structure

```
.
├── src/
│   └── app.js                # Main Express server logic and API endpoints
├── public/
│   ├── index.html            # Frontend HTML, CSS, and JavaScript
│   └── generated/            # Directory to store generated Terraform files (.tf)
├── uploads/                  # Directory to store uploaded diagram images
├── services/
│   └── geminiEditorAgent.js  # (Assumed) Contains logic for Gemini code editing
├── .env                      # Environment variables (not committed)
├── package.json              # Node.js project dependencies
├── package-lock.json         # Dependency lock file
└── README.md                 # This file
```

## Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests.

## License

MIT, Apache 2.0

---
https://docs.localstack.cloud/aws/sample-apps/
