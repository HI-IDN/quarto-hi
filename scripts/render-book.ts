// Post-render step for the demo site: render the book example into _site/book.
// A Quarto book is its own project, so it needs the theme extension, HÍ
// images, article styles and bibliography inside book/. They are copied here (and gitignored) so the repo keeps
// a single copy of the theme.

function copyDir(src: string, dest: string) {
  Deno.mkdirSync(dest, { recursive: true });
  for (const entry of Deno.readDirSync(src)) {
    const from = `${src}/${entry.name}`;
    const to = `${dest}/${entry.name}`;
    if (entry.isDirectory) copyDir(from, to);
    else Deno.copyFileSync(from, to);
  }
}

for (const dir of ["_extensions", "img/hi", "styles"]) {
  try {
    Deno.removeSync(`book/${dir}`, { recursive: true });
  } catch {
    // not there yet
  }
  copyDir(dir, `book/${dir}`);
}
for (const file of ["article.bib", "apa.csl"]) {
  Deno.copyFileSync(file, `book/${file}`);
}

const bin = Deno.env.get("QUARTO_BIN_PATH");
const quarto = bin ? `${bin}/quarto` : "quarto";
const { code } = await new Deno.Command(quarto, {
  args: ["render", "book"],
  stdout: "inherit",
  stderr: "inherit",
}).output();
if (code !== 0) Deno.exit(code);
