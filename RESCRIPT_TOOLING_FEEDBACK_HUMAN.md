> This file is only for humans to add to.

## MCP command to run the compiler intermediately

It seems the model defaults to rerunning the full compiler every time via the full build command. This is good but it's also slow. We could give it an MCP command that runs the compiler (in an LLM mode?) only for a single file. That should probably help.

## Bindings guide

The AI tried to write basic bindings, and got it mostly right, but tried to use old `@bs.` prefixed attributes. We should provide a concise bindings guide. Maybe pulling the one from the docs is enough?

## Deprectated/removed syntax in the training data

The AI tried to use `@bs.` prefixed attributes. We should probably warn about them being deprecated and refer to their modern equivalents.
