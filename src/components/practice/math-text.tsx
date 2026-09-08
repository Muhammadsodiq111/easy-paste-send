import katex from "katex";
import "katex/dist/katex.min.css";
import type { ReactNode } from "react";

import { toDesmosLatex } from "@/lib/desmos-format";

function renderTex(tex: string, display: boolean) {
  try {
    return katex.renderToString(tex, {
      displayMode: display,
      throwOnError: false,
      strict: false,
      output: "html",
    });
  } catch {
    return null;
  }
}

function Tex({ tex, display = false }: { tex: string; display?: boolean }) {
  const html = renderTex(tex, display);
  if (!html) return <span>{tex}</span>;
  return (
    <span
      className={display ? "block text-center" : "inline-block align-baseline"}
      // KaTeX output is generated locally from author content, not remote HTML.
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}

/** A token that clearly reads as math inside a sentence: 2y, x_1, 3x^2, -12, 42. */
const AUTO_MATH = /^-?(?:\d+(?:\.\d+)?)?[A-Za-z]?(?:\^-?\w+|_\w+)?$/;

function isAutoMath(token: string) {
  const t = token.replace(/[.,;:!?]+$/, "");
  if (!t) return false;
  if (/^[A-Za-z]+$/.test(t) && t.length > 1) return false; // plain words
  if (!/[0-9]/.test(t) && t.length === 1 && !/[a-zA-Z]/.test(t)) return false;
  return AUTO_MATH.test(t) && /[0-9A-Za-z]/.test(t);
}

/** A word that can take part in a formula: 2y, (y, +, 2)/2, =, 1. */
const MATH_WORD = /^[A-Za-z0-9().+\-*/^_=<>|,]+$/;

function isMathWord(token: string) {
  const core = token.replace(/[.,;:!?]+$/, "");
  if (!core) return false;
  if (!MATH_WORD.test(core)) return false;
  if (/^[A-Za-z]{2,}$/.test(core)) return false; // plain words like "if" or "value"
  return /[0-9]/.test(core) || /[+\-*/^=<>()]/.test(core) || /^[A-Za-z]$/.test(core);
}


/** Inline segments: **bold**, *italic*, $math$, plus auto-detected math tokens. */
function renderInline(text: string, keyBase: string): ReactNode[] {
  const out: ReactNode[] = [];
  const re = /(\*\*[^*]+\*\*|\*[^*]+\*|\$[^$]+\$)/g;
  let last = 0;
  let m: RegExpExecArray | null;
  let i = 0;

  const pushPlain = (chunk: string, k: string) => {
    if (!chunk) return;
    const pieces = chunk.split(/(\s+)/).filter((p) => p !== "");
    let idx = 0;
    let group = 0;

    while (idx < pieces.length) {
      const piece = pieces[idx]!;
      if (/^\s+$/.test(piece)) {
        out.push(piece);
        idx += 1;
        continue;
      }

      // Collect the longest run of consecutive math-looking words so a whole
      // expression like "(y + 2)/2 - 3 = 1" renders as one typeset formula.
      const run: string[] = [];
      let scan = idx;
      let lastMath = idx;
      while (scan < pieces.length) {
        const p = pieces[scan]!;
        if (/^\s+$/.test(p)) {
          run.push(" ");
          scan += 1;
          continue;
        }
        if (!isMathWord(p)) break;
        run.push(p);
        lastMath = scan;
        scan += 1;
      }

      const consumed = run.length ? pieces.slice(idx, lastMath + 1) : [];
      const joined = consumed.join("");
      const trail = joined.match(/[.,;:!?]+$/)?.[0] ?? "";
      const core = trail ? joined.slice(0, -trail.length) : joined;

      const isExpression = /[+\-*/^=<>]/.test(core) && core.replace(/\s/g, "").length > 2;
      if (core && (isExpression || isAutoMath(core))) {
        out.push(<Tex key={`${k}-m${(group += 1)}`} tex={toDesmosLatex(core)} />);
        if (trail) out.push(trail);
        idx = lastMath + 1;
        continue;
      }

      out.push(piece);
      idx += 1;
    }
  };


  while ((m = re.exec(text))) {
    pushPlain(text.slice(last, m.index), `${keyBase}-p${i}`);
    const tok = m[0];
    if (tok.startsWith("$")) {
      out.push(<Tex key={`${keyBase}-t${i}`} tex={toDesmosLatex(tok.slice(1, -1))} />);
    } else if (tok.startsWith("**")) {
      out.push(
        <strong key={`${keyBase}-b${i}`} className="font-semibold">
          {tok.slice(2, -2)}
        </strong>,
      );
    } else {
      out.push(
        <em key={`${keyBase}-i${i}`} className="italic">
          {tok.slice(1, -1)}
        </em>,
      );
    }
    last = m.index + tok.length;
    i += 1;
  }
  pushPlain(text.slice(last), `${keyBase}-p${i}`);
  return out;
}

/** Prose if the line reads like a sentence rather than a standalone equation. */
function isProse(line: string) {
  const s = line.trim();
  if (/^note:/i.test(s)) return true;
  if (s.endsWith(":")) return true;
  const words = s.split(/\s+/).filter((w) => /^[A-Za-z]{3,}$/.test(w));
  return words.length >= 2;
}

/**
 * Renders one stored explanation line: sentences stay left-aligned prose with
 * inline math, standalone equations become centered display math.
 */
export function MathLine({ line, index = 0 }: { line: string; index?: number }) {
  const text = line.replace(/^note:\s*/i, "").trim();
  if (!text) return null;

  if (isProse(text)) {
    return <p className="text-foreground text-[15px] leading-relaxed">{renderInline(text, `l${index}`)}</p>;
  }

  return (
    <div className="py-1">
      <Tex tex={toDesmosLatex(text)} display />
    </div>
  );
}

export function MathExplanation({ lines }: { lines: readonly string[] }) {
  return (
    <div className="space-y-3">
      {lines.map((line, i) => (
        <MathLine key={`${line}-${i}`} line={line} index={i} />
      ))}
    </div>
  );
}
