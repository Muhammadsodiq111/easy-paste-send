import { ALL_LESSONS, type LessonEntry } from "@/lib/courses";
import { MODULE_CATALOG } from "@/lib/module-catalog";

function norm(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
}

const STOP = new Set(["and", "or", "the", "of", "in", "for", "a", "an", "to", "with", "one", "two", "variable", "variables"]);
function words(s: string) {
  return new Set(norm(s).split(" ").filter((w) => w && !STOP.has(w)));
}

function bestByOverlap(target: string, pool: LessonEntry[]): LessonEntry | undefined {
  const t = words(target);
  let best: LessonEntry | undefined;
  let bestScore = 0;
  for (const l of pool) {
    const lw = words(l.title);
    let score = 0;
    for (const w of t) if (lw.has(w)) score += 1;
    if (score > bestScore) {
      bestScore = score;
      best = l;
    }
  }
  return best;
}

/** Group (e.g. "Algebra") a module belongs to, per the catalog. */
export function moduleGroup(moduleTitle: string): { subject: "math" | "english"; group: string } | undefined {
  for (const subject of ["math", "english"] as const) {
    for (const topic of MODULE_CATALOG[subject]) {
      if (topic.modules.some((m) => m.title === moduleTitle)) return { subject, group: topic.title };
    }
  }
  return undefined;
}

/** Best matching lesson for a practice subtopic within a module. */
export function findLessonForPractice(moduleTitle: string, subtopicTitle: string): LessonEntry | undefined {
  const exact = (title: string) => ALL_LESSONS.find((l) => norm(l.title) === norm(title));
  const direct = exact(subtopicTitle) ?? exact(moduleTitle);
  if (direct) return direct;

  const info = moduleGroup(moduleTitle);
  const pool = info
    ? ALL_LESSONS.filter((l) => l.subject === info.subject && norm(l.group) === norm(info.group))
    : ALL_LESSONS;
  return (
    bestByOverlap(subtopicTitle, pool) ??
    bestByOverlap(moduleTitle, pool) ??
    bestByOverlap(moduleTitle, ALL_LESSONS) ??
    pool[0]
  );
}

/** The chapter that follows the given one in the catalog order, if any. */
export function nextModuleTitle(moduleTitle: string): string | undefined {
  const flat = (["math", "english"] as const).flatMap((s) =>
    MODULE_CATALOG[s].flatMap((t) => t.modules.map((m) => m.title)),
  );
  const i = flat.indexOf(moduleTitle);
  if (i < 0 || i === flat.length - 1) return undefined;
  return flat[i + 1];
}
