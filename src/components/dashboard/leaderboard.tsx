import { useQuery } from "@tanstack/react-query";
import { currentUserQuery, leaderboardQuery } from "@/lib/leaderboard";

const MEDAL = ["text-amber", "text-muted-foreground", "text-flame"];

export function LeaderboardCard() {
  const { data: rows = [], isLoading } = useQuery(leaderboardQuery);
  const { data: meId } = useQuery(currentUserQuery);

  const me = rows.find((r) => r.userId === meId);

  return (
    <section className="overflow-hidden rounded-3xl border border-border bg-card shadow-[0_20px_60px_-45px_rgba(20,40,90,0.45)]">
      <div className="flex flex-wrap items-center justify-between gap-3 px-5 pt-5">
        <h3 className="font-display text-base font-semibold text-foreground">Leaderboard</h3>
        {me ? (
          <span className="rounded-full bg-primary px-3 py-1.5 text-xs font-bold text-primary-foreground">
            Your rank #{me.rank} of {rows.length}
          </span>
        ) : null}
      </div>

      <div className="p-5">
        {isLoading ? (
          <p className="py-10 text-center text-sm text-muted-foreground">Loading rankings…</p>
        ) : rows.length === 0 ? (
          <p className="py-10 text-center text-sm text-muted-foreground">
            No rankings yet — answer some questions to get on the board.
          </p>
        ) : (
          <ul className="space-y-1.5">
            {rows.slice(0, 20).map((r, i) => (
              <li
                key={r.userId}
                className={`flex items-center gap-3 rounded-2xl border px-4 py-2.5 text-sm ${
                  r.userId === meId ? "border-primary bg-primary/5" : "border-border"
                }`}
              >
                <span
                  className={`w-7 shrink-0 font-display text-base font-semibold ${
                    MEDAL[i] ?? "text-muted-foreground"
                  }`}
                >
                  {r.rank}
                </span>
                <span className="min-w-0 flex-1 truncate font-semibold text-foreground">
                  {r.userId === meId ? "You" : r.name}
                </span>
                <span className="shrink-0 text-muted-foreground">
                  {r.correct}/{r.attempted}
                </span>
                <span className="w-14 shrink-0 text-right font-bold text-emerald">
                  {Math.round(r.accuracy)}%
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </section>
  );
}
