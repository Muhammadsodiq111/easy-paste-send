import { supabase } from "@/integrations/supabase/external";

export type LeaderboardRow = {
  userId: string;
  name: string;
  correct: number;
  attempted: number;
  accuracy: number;
  rank: number;
};

/**
 * Site-wide ranking. Backed by the `public.leaderboard()` security-definer
 * function on the Supabase project (see supabase/new-project/schema.sql).
 * Returns an empty list when the function is not installed yet.
 */
export const leaderboardQuery = {
  queryKey: ["leaderboard"],
  queryFn: async (): Promise<LeaderboardRow[]> => {
    const { data, error } = await (
      supabase as unknown as {
        rpc: (fn: string) => Promise<{ data: unknown; error: { message: string } | null }>;
      }
    ).rpc("leaderboard");
    if (error) return [];
    const rows = Array.isArray(data) ? (data as Record<string, unknown>[]) : [];
    return rows.map((r, i) => ({
      userId: String(r["user_id"] ?? ""),
      name: String(r["name"] ?? "Student"),
      correct: Number(r["correct"] ?? 0),
      attempted: Number(r["attempted"] ?? 0),
      accuracy: Number(r["accuracy"] ?? 0),
      rank: Number(r["rank"] ?? i + 1),
    }));
  },
  staleTime: 60_000,
};

export async function currentUserId(): Promise<string | null> {
  const { data } = await supabase.auth.getUser();
  return data.user?.id ?? null;
}

export const currentUserQuery = {
  queryKey: ["leaderboard-me"],
  queryFn: currentUserId,
  staleTime: 5 * 60_000,
};
