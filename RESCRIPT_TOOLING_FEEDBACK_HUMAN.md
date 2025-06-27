> This file is only for humans to add to.

## MCP command to run the compiler intermediately

It seems the model defaults to rerunning the full compiler every time via the full build command. This is good but it's also slow. We could give it an MCP command that runs the compiler (in an LLM mode?) only for a single file. That should probably help.
