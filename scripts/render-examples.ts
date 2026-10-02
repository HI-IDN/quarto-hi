// Post-render step for the demo site: render the nested example projects
// (book/ -> _site/book, package/ -> _site/package).
// Each example is its own Quarto project, so it needs the HÍ images, shared
// styles and bibliography inside its own folder. They are copied here (and
// gitignored) so the repo keeps a single copy of each.

const examples = ["book", "package"];
const sharedDirs = ["img/hi", "styles"];
const sharedFiles = ["article.bib", "apa.csl"];

function copyDir(src: string, dest: string) {
  Deno.mkdirSync(dest, { recursive: true });
  for (const entry of Deno.readDirSync(src)) {
    const from = `${src}/${entry.name}`;
    const to = `${dest}/${entry.name}`;
    if (entry.isDirectory) copyDir(from, to);
    else Deno.copyFileSync(from, to);
  }
}

const bin = Deno.env.get("QUARTO_BIN_PATH");
const quarto = bin ? `${bin}/quarto` : "quarto";

for (const example of examples) {
  for (const dir of sharedDirs) {
    try {
      Deno.removeSync(`${example}/${dir}`, { recursive: true });
    } catch {
      // not there yet
    }
    copyDir(dir, `${example}/${dir}`);
  }
  for (const file of sharedFiles) {
    Deno.copyFileSync(file, `${example}/${file}`);
  }

  const { code } = await new Deno.Command(quarto, {
    args: ["render", example],
    stdout: "inherit",
    stderr: "inherit",
  }).output();
  if (code !== 0) Deno.exit(code);
}
