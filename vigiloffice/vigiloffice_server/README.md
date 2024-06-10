# VigilOffice Server instructions

## Install

To install Serverpod follow these steps:

### 1 Install Docker

 Start by installing Docker on your machine. Docker is required to run Postgres and Redis. You can download Docker from the official website and follow the installation instructions for your operating system.
 See <https://docs.docker.com/get-docker/>

### 2 Install Flutter

To install Flutter, follow these steps:

1. Start by downloading the Flutter SDK from the official website. Choose the version that matches your operating system. You will need Flutter version 3.7 or later. <https://flutter.dev/docs/get-started/install>

2. Extract the downloaded file to a location on your machine.

3. Add the Flutter SDK to your system's PATH variable. This allows you to run Flutter commands from any directory in your terminal or command prompt.

4. Open a terminal or command prompt and run the following command to verify that Flutter is correctly installed:

    ```shell
    flutter doctor
    ```

    This command will check for any missing dependencies and provide guidance on how to install them.

5. Once Flutter is installed and the doctor command shows no issues, you can proceed to set up an editor of your choice. Flutter supports a variety of editors, including Visual Studio Code, Android Studio, and IntelliJ IDEA.

6. Install the necessary plugins and extensions for your chosen editor to enable Flutter development.

7. You are now ready to create and run Flutter applications on your machine.

### 3 Install Serverpod

To install Serverpod follow these steps:

1. Open a terminal or command prompt.

2. Run the following command to install Serverpod CLI using Dart Pub:

    ```shell
    dart pub global activate serverpod_cli
    ```

    This command will install the Serverpod CLI globally on your machine.

3. Now test the installation by running:

    ```shell
    serverpod 
    ```

    If everything is correctly configured, the help for the serverpod command is now displayed.

### 4 (Optional) Install VSCode Extension

The Serverpod VS Code extension makes it easy to work with your Serverpod projects. It provides real-time diagnostics and syntax highlighting for model files in your project.

Install the extension from the VS Code Marketplace: [Serverpod extension](https://marketplace.visualstudio.com/items?itemName=serverpod.serverpod)

## Run the server

1. Start Docker desktop

2. Open a terminal inside the `vigiloffice_server` folder

3. Start Docker containers with `docker compose up --build --detach`.

4. **Warning: Before continuing, ensure that you have the `passwords.yaml` file in the config folder. Failure to have this file will result in server shutting down.**

5. Run the server with `dart bin/main.dart --apply-migrations`.

## Generate code after editing files

Whenever some file for the server is modified be sure to do the following:

1. Open a terminal inside the `vigiloffice_server` folder

2. Run `serverpod generate`.

3. If not already started, start Docker containers with `docker compose up --build --detach`.

4. Run `dart bin/main.dart --role maintenance --apply-migrations`. The maintenance role will shutdown the server once the migration
has been applied, remove the role if you want to run the server as normal.
