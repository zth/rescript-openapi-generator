# Development Setup Guide

## Required Tools & Workflow

### Node.js Version

- **Always use `nvm use`** to switch to the correct Node.js version before any development work
- The project uses Node.js version specified in `.nvmrc` (currently v20)

### Package Manager

- **Always use `yarn`** instead of `npm` for all commands
- Run `yarn` instead of `npm install`
- Run `yarn <script>` instead of `npm run <script>`

### Development Workflow

1. Start every development session with: `nvm use`
2. Use yarn for all package management and script execution
3. Common commands:
   - `yarn res:build` - Build ReScript
   - `yarn res:dev` - Watch mode development
   - `yarn test` - Run tests
   - `yarn res:format` - Format code

## AI Assistant Instructions

When working on this project, the AI assistant should:

1. **Always run `nvm use` first** when starting work
2. **Always use `yarn` commands** instead of `npm`
3. Reference this file for development preferences
