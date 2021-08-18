# browser-exts

> Browser extensions for various purposes.

In any subdirectory, `yarn dev` will re-build extensions when any file changes,
and `yarn build` will produce minified javascript.

In Chrome, enable Developer Mode for extensions, and then load each unpacked
extension from the `dist` directory produced by `yarn dev`/`yarn build`.
