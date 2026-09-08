import { useMemo, useState } from "react";
import { useQuery, useSuspenseQuery } from "@tanstack/react-query";
import { DIFFICULTY_LEVELS, questionBankQuery, type Level } from "@/lib/practice";
import { useTrackerProgress } from "@/lib/tracker-progress";
import { LeaderboardCard } from "@/components/dashboard/leaderboard";
import {
  formatHours,
  STUDY_AREA_LABEL,
  studyTimeQuery,
  totalsByArea,
  type StudyArea,
} from "@/lib/study-time";

type Tf = "week" | "month" | "all";

const LEVEL_META: Record<Level, { label: string; color: string; text: string }> = {
  easy: { label: "Easy", color: "bg-emerald", text: "text-emerald" },
  medium: { label: "Medium", color: "bg-amber", text: "text-amber" },
  hard: { label: "Hard", color: "bg-flame", text: "text-flame" },
  challenge: { label: "Challenge", color: "bg-violet", text: "text-violet" },
};

const AREA_COLORS: Record<StudyArea, string> = {
  practice: "var(--color-primary)",
  mocks: "var(--color-violet)",
  courses: "var(--color-emerald)",
  vocab: "var(--color-amber)",
  review: "var(--color-flame)",
  lessons: "var(--color-primary)",
};

const AREA_ORDER: StudyArea[] = ["practice", "mocks", "lessons", "vocab", "review"];

export function StatsSection() {
  const { data: rows } = useSuspenseQuery(questionBankQuery);
  const { entry } = useTrackerProgress();
  const [timeTf, setTimeTf] = useState<Tf>("all");
  const { data: timeRows = [] } = useQuery(studyTimeQuery);

  const DIFFICULTY = useMemo(
    () =>
      DIFFICULTY_LEVELS.map((level) => {
        const levelRows = rows.filter((r) => r.level === level);
        const statuses = levelRows.map((r) => entry(r.id).status);
        const done = statuses.filter((s) => s !== "unattempted").length;
        const correct = statuses.filter((s) => s === "correct").length;
        return {
          ...LEVEL_META[level],
          done,
          correct,
          acc: done ? Math.round((correct / done) * 100) : 0,
          total: levelRows.length,
        };
      }),
    [rows, entry],
  );

  const attempted = DIFFICULTY.reduce((s, d) => s + d.done, 0);
  const correct = DIFFICULTY.reduce((s, d) => s + d.correct, 0);
  const accuracy = attempted ? Math.round((correct / attempted) * 100) : 0;

  const areaTotals = useMemo(() => totalsByArea(timeRows, timeTf), [timeRows, timeTf]);
  const totalSeconds = AREA_ORDER.reduce((s, a) => s + areaTotals[a], 0);

  return (
    <div className="space-y-5">
      <div className="grid gap-5 xl:grid-cols-2">
        <Card>
          <CardHeader title="Accuracy" />
          <div className="flex flex-col items-center gap-6 p-5 sm:flex-row">
            <Donut
              percent={accuracy}
              center={`${accuracy}%`}
              sub={`${correct} of ${attempted} correct`}
            />
            <div className="w-full flex-1 space-y-4">
              {DIFFICULTY.map((d) => (
                <div key={d.label}>
                  <div className="flex items-baseline justify-between text-sm">
                    <span className="font-display font-semibold text-foreground">{d.label}</span>
                    <span className="text-muted-foreground">
                      {d.correct}/{d.done} correct
                      <span className={`ml-3 font-bold ${d.text}`}>{d.acc}% acc</span>
                    </span>
                  </div>
                  <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-muted">
                    <div
                      className={`h-full rounded-full ${d.color}`}
                      style={{ width: `${d.acc}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </Card>

        <Card>
          <CardHeader title="Time by Area">
            <Timeframe value={timeTf} onChange={setTimeTf} />
          </CardHeader>
          <div className="flex flex-col items-center gap-6 p-5 sm:flex-row">
            <Donut
              percent={totalSeconds ? 100 : 0}
              center={formatHours(totalSeconds)}
              sub="total"
            />
            <ul className="w-full flex-1 space-y-2">
              {AREA_ORDER.map((area) => (
                <li key={area} className="flex items-center gap-2 text-sm">
                  <span
                    className="size-2.5 shrink-0 rounded-[3px]"
                    style={{ backgroundColor: AREA_COLORS[area] }}
                  />
                  <span className="min-w-0 flex-1 truncate text-foreground">
                    {STUDY_AREA_LABEL[area]}
                  </span>
                  <span className="font-bold text-muted-foreground">
                    {formatHours(areaTotals[area])}
                  </span>
                </li>
              ))}
            </ul>
          </div>
        </Card>
      </div>

      <LeaderboardCard />
    </div>
  );
}



function Timeframe({ value, onChange }: { value: Tf; onChange: (v: Tf) => void }) {
  const opts: { key: Tf; label: string }[] = [
    { key: "week", label: "This Week" },
    { key: "month", label: "This Month" },
    { key: "all", label: "All Time" },
  ];
  return (
    <div className="flex gap-2">
      {opts.map((o) => (
        <button
          key={o.key}
          type="button"
          onClick={() => onChange(o.key)}
          className={`rounded-full px-3 py-1.5 text-xs font-bold transition-colors ${
            value === o.key
              ? "bg-primary text-primary-foreground"
              : "border border-border bg-card text-muted-foreground"
          }`}
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}

function Donut({ percent, center, sub }: { percent: number; center: string; sub: string }) {
  const r = 52;
  const c = 2 * Math.PI * r;
  return (
    <div className="relative grid size-36 shrink-0 place-items-center">
      <svg viewBox="0 0 130 130" className="size-36 -rotate-90">
        <circle cx="65" cy="65" r={r} fill="none" strokeWidth="16" className="stroke-muted" />
        <circle
          cx="65"
          cy="65"
          r={r}
          fill="none"
          strokeWidth="16"
          strokeLinecap="round"
          className="stroke-primary"
          strokeDasharray={`${(percent / 100) * c} ${c}`}
        />
      </svg>
      <div className="absolute text-center">
        <p className="font-display text-2xl font-semibold text-foreground">{center}</p>
        <p className="text-[11px] text-muted-foreground">{sub}</p>
      </div>
    </div>
  );
}

function Heatmap() {
  return (
    <div className="flex gap-1.5 overflow-x-auto">
      {Array.from({ length: 13 }).map((_, w) => (
        <div key={w} className="flex flex-col gap-1.5">
          {Array.from({ length: 7 }).map((__, d) => (
            <span key={d} className="size-4 rounded-[4px] bg-muted" />
          ))}
        </div>
      ))}
    </div>
  );
}

function Card({ children }: { children: React.ReactNode }) {
  return (
    <section className="overflow-hidden rounded-3xl border border-border bg-card shadow-[0_20px_60px_-45px_rgba(20,40,90,0.45)]">
      {children}
    </section>
  );
}

function CardHeader({ title, children }: { title: string; children?: React.ReactNode }) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-3 px-5 pt-5">
      <h3 className="font-display text-base font-semibold text-foreground">{title}</h3>
      {children}
    </div>
  );
}
