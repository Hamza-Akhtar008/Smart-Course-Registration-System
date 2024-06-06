# Contributing to the Smart Course Registration System

Thank you for your interest in contributing to the Smart Course Registration System project! We appreciate your help and aim to make the process as easy as possible. Below are the guidelines to help you get started:

## Getting Started

1. **Fork the Repository**: Start by forking the main repository to your GitHub account.
2. **Clone the Repository**: Clone the forked repository to your local machine.
    ```bash
    git clone https://github.com/your-username/smart-course-registration.git
    ```
3. **Set Upstream Remote**: Add the original repository as an upstream remote to keep your fork in sync.
    ```bash
    git remote add upstream https://github.com/original-owner/smart-course-registration.git
    ```

## Branching and Commit Messages

1. **Create a Branch**: Always create a new branch for your work.
    ```bash
    git checkout -b feature/your-feature-name
    ```
2. **Commit Messages**: Write clear, concise commit messages. Follow the convention:
    - Use the imperative mood in the subject line.
    - Limit the subject line to 50 characters.
    - Reference issues and pull requests liberally.

    Example:
    ```plaintext
    Add user authentication feature

    This commit includes the implementation of a new user authentication
    feature using JWT. The feature allows users to securely log in and
    manage their sessions.
    ```

## Code Style and Testing

1. **Coding Standards**: Adhere to the coding standards used in the project. Use the existing codebase as a guide.
2. **Run Tests**: Ensure all tests pass before pushing your code. Add tests for new features.
    ```bash
    npm test
    ```

## Pull Requests

1. **Sync with Upstream**: Before creating a pull request, make sure your branch is up-to-date with the upstream main branch.
    ```bash
    git fetch upstream
    git checkout main
    git merge upstream/main
    ```
2. **Create Pull Request**: Push your branch to your fork and create a pull request from GitHub.
3. **Pull Request Description**: Provide a detailed description of your changes. Reference related issues.

    Example:
    ```plaintext
    ## Description

    Added a new feature for user authentication using JWT.

    ## Related Issue

    Fixes #123

    ## Type of Change

    - [x] New feature
    - [ ] Bug fix
    - [ ] Documentation update

    ## Testing

    Added unit tests for authentication routes.
    ```

## Review Process

1. **Review Feedback**: Be responsive to feedback and make necessary changes.
2. **Merge Approval**: Once approved, your pull request will be merged by a project maintainer.

## Community

1. **Join Discussions**: Participate in project discussions on GitHub issues and pull requests.
2. **Respectful Interaction**: Maintain a respectful and collaborative environment.

For any questions or further assistance, feel free to contact the maintainers or join our project Slack channel.

Thank you for contributing to the Smart Course Registration System!
