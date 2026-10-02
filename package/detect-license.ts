// Pre-render step: read the licence from the repository's LICENSE file (the
// same file GitHub uses for the licence shown on the repo page) and write it to
// _variables.yml, so pages and the footer can use {{< var license >}}.
// Looks in this folder first, then in parent folders up to the git root.

const candidates = ["LICENSE", "LICENSE.md", "LICENSE.txt", "LICENCE", "COPYING"];

// First match wins, so more specific patterns come first.
const known: [RegExp, string][] = [
  [/MIT License/i, "MIT"],
  [/Apache License,?\s+Version 2\.0/i, "Apache-2.0"],
  [/GNU AFFERO GENERAL PUBLIC LICENSE\s+Version 3/i, "AGPL-3.0"],
  [/GNU LESSER GENERAL PUBLIC LICENSE\s+Version 3/i, "LGPL-3.0"],
  [/GNU GENERAL PUBLIC LICENSE\s+Version 3/i, "GPL-3.0"],
  [/GNU GENERAL PUBLIC LICENSE\s+Version 2/i, "GPL-2.0"],
  [/BSD 3-Clause/i, "BSD-3-Clause"],
  [/BSD 2-Clause/i, "BSD-2-Clause"],
  [/Mozilla Public License,?\s+(Version|v\.?)\s*2\.0/i, "MPL-2.0"],
  [/Attribution-ShareAlike 4\.0/i, "CC BY-SA 4.0"],
  [/Attribution 4\.0 International/i, "CC BY 4.0"],
  [/CC0 1\.0/i, "CC0-1.0"],
  [/This is free and unencumbered software/i, "Unlicense"],
];

function findLicense(): string | undefined {
  let dir = Deno.cwd();
  while (true) {
    for (const name of candidates) {
      try {
        if (Deno.statSync(`${dir}/${name}`).isFile) return `${dir}/${name}`;
      } catch {
        // not here
      }
    }
    let atGitRoot = false;
    try {
      atGitRoot = !!Deno.statSync(`${dir}/.git`);
    } catch {
      // not a git root
    }
    const parent = dir.replace(/[\\/][^\\/]+$/, "");
    if (atGitRoot || parent === dir) return undefined;
    dir = parent;
  }
}

const path = findLicense();
let license = "";
if (path) {
  const text = Deno.readTextFileSync(path);
  license = known.find(([re]) => re.test(text))?.[1] ??
    text.split("\n").find((line) => line.trim())?.trim() ?? "";
}

Deno.writeTextFileSync(
  "_variables.yml",
  `# Written by detect-license.ts from ${path ? path.split(/[\\/]/).pop() : "(no LICENSE found)"}; do not edit\n` +
    `license: "${license.replaceAll('"', '\\"')}"\n`,
);
