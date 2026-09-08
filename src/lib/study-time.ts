import { useEffect, useRef } from "react";
import { supabase } from "@/integrations/supabase/external";

export const STUDY_AREAS = [
  "practice",
  "mocks",
  "courses",
  "vocab",
  "review",
  "lessons",
] as const;

export type StudyArea = (typeof STUDY_AREAS)[number];

export const STUDY_AREA_LABEL: Record<StudyArea, string> = {
  practice: "Practice Problems",
  mocks: "Mock Exams",
  courses: "Courses",
  vocab: "Vocab",
  review: "Mistake Review",
  lessons: "Lessons",
};

type Rpc = {
  rpc: (
    fn: string,
    args?: Record<string, unknown>,
  ) => Promise<{ data: unknown; error: { message: string } | null }>;
};

async function addStudyTime(area: StudyArea, seconds: number) {
  if (seconds < 5) return;
  const { data } = await supabase.auth.getUser();
  if (!data.user) return;
  await (supabase as unknown as Rpc).rpc("add_study_time", {
    _area: area,
    _seconds: Math.round(seconds),
  });
}

/**
 * Counts the seconds a student actually spends on a page (tab visible only)
 * and pushes them to `public.study_time` every minute plus on unmount.
 */
export function useStudyClock(area: StudyArea) {
  const pending = useRef(0);

  useEffect(() => {
    let last = Date.now();

    const accumulate = () => {
      const now = Date.now();
      if (document.visibilityState === "visible") {
        const delta = (now - last) / 1000;
        // Ignore idle gaps longer than 5 minutes (tab left open, user away).
        if (delta > 0 && delta < 300) pending.current += delta;
      }
      last = now;
    };

    const flush = () => {
      accumulate();
      const seconds = pending.current;
      if (seconds >= 5) {
        pending.current = 0;
        void addStudyTime(area, seconds);
      }
    };

    const tick = window.setInterval(flush, 60_000);
    document.addEventListener("visibilitychange", accumulate);
    window.addEventListener("blur", accumulate);
    window.addEventListener("focus", accumulate);

    return () => {
      window.clearInterval(tick);
      document.removeEventListener("visibilitychange", accumulate);
      window.removeEventListener("blur", accumulate);
      window.removeEventListener("focus", accumulate);
      flush();
    };
  }, [area]);
}

export type StudyTimeRow = { area: StudyArea; seconds: number; day: string };

export const studyTimeQuery = {
  queryKey: ["study-time"],
  queryFn: async (): Promise<StudyTimeRow[]> => {
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user) return [];
    const { data, error } = await (
      supabase as unknown as {
        from: (t: string) => {
          select: (c: string) => {
            eq: (
              c: string,
              v: string,
            ) => Promise<{ data: unknown; error: { message: string } | null }>;
          };
        };
      }
    )
      .from("study_time")
      .select("area, seconds, day")
      .eq("user_id", auth.user.id);
    if (error) return [];
    const rows = Array.isArray(data) ? (data as Record<string, unknown>[]) : [];
    return rows.map((r) => ({
      area: String(r["area"] ?? "practice") as StudyArea,
      seconds: Number(r["seconds"] ?? 0),
      day: String(r["day"] ?? ""),
    }));
  },
  staleTime: 30_000,
};

/** Sums seconds per area inside a timeframe ("week" | "month" | "all"). */
export function totalsByArea(rows: StudyTimeRow[], timeframe: "week" | "month" | "all") {
  const cutoff = new Date();
  if (timeframe === "week") cutoff.setUTCDate(cutoff.getUTCDate() - 7);
  else if (timeframe === "month") cutoff.setUTCMonth(cutoff.getUTCMonth() - 1);
  else cutoff.setUTCFullYear(1970);

  const totals: Record<StudyArea, number> = {
    practice: 0,
    mocks: 0,
    courses: 0,
    vocab: 0,
    review: 0,
    lessons: 0,
  };
  for (const row of rows) {
    if (row.day && new Date(`${row.day}T00:00:00Z`) < cutoff) continue;
    if (row.area in totals) totals[row.area] += row.seconds;
  }
  return totals;
}

export function formatHours(seconds: number) {
  const hours = seconds / 3600;
  if (hours >= 10) return `${Math.round(hours)}h`;
  if (hours >= 1) return `${hours.toFixed(1)}h`;
  const minutes = Math.round(seconds / 60);
  return minutes > 0 ? `${minutes}m` : "0h";
}
